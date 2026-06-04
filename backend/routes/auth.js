const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { OAuth2Client } = require('google-auth-library');
const { query } = require('../config/db');
const { createSession } = require('../utils/sessionStore');

const GOOGLE_WEB_CLIENT_ID = process.env.GOOGLE_WEB_CLIENT_ID || '';
const googleClient = new OAuth2Client(GOOGLE_WEB_CLIENT_ID);

router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Email and Password are required.'
        });
    }

    try {
        const sql = `
            SELECT u.*, r.name as roleName
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.email = ?
        `;
        const users = await query(sql, [email]);

        if (users.length === 0) {
            return res.status(401).json({
                success: false,
                message: 'Authentication Failure: Invalid email or password.'
            });
        }

        const user = users[0];
        const passwordMatch = await bcrypt.compare(password, user.password);
        const isPlainTextMatch = password === user.password;

        if (!passwordMatch && !isPlainTextMatch) {
            return res.status(401).json({
                success: false,
                message: 'Authentication Failure: Invalid email or password.'
            });
        }

        const token = createSession(user);

        return res.status(200).json({
            success: true,
            message: 'Authentication Successful',
            token: token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.roleName
            }
        });

    } catch (err) {
        console.error('Error during database login:', err);
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error during login verification.'
        });
    }
});

router.post('/register', async (req, res) => {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Name, email, and password are required.'
        });
    }

    if (name.trim().length < 2) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Name must be at least 2 characters.'
        });
    }

    const emailRegex = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (!emailRegex.test(email)) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Invalid email format.'
        });
    }

    if (password.length < 6) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Password must be at least 6 characters.'
        });
    }

    try {
        const checkSql = 'SELECT * FROM users WHERE email = ?';
        const existing = await query(checkSql, [email]);

        if (existing.length > 0) {
            return res.status(409).json({
                success: false,
                message: 'Registration Failed: This email address is already registered.'
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const insertSql = 'INSERT INTO users (name, email, password, role_id) VALUES (?, ?, ?, 2)';
        const result = await query(insertSql, [name.trim(), email.toLowerCase(), hashedPassword, 2]);

        const newUser = {
            id: result.insertId,
            name: name.trim(),
            email: email.toLowerCase(),
            roleName: 'User'
        };

        const token = createSession(newUser);

        return res.status(201).json({
            success: true,
            message: 'Registration Successful! Welcome to Genshin Import.',
            token: token,
            user: {
                id: newUser.id,
                name: newUser.name,
                email: newUser.email,
                role: newUser.roleName
            }
        });

    } catch (err) {
        console.error('Error during registration:', err);
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error during registration.'
        });
    }
});

router.post('/oauth', async (req, res) => {
    const { provider, idToken, email, name } = req.body;

    if (!provider || !idToken) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: provider and idToken are required.'
        });
    }

    try {
        let verifiedEmail = email;
        let verifiedName = name;

        if (provider === 'Google') {
            if (!GOOGLE_WEB_CLIENT_ID) {
                console.log('⚠️  GOOGLE_WEB_CLIENT_ID not set in .env — skipping token verification in dev mode.');
                if (!email) {
                    return res.status(400).json({
                        success: false,
                        message: 'Dev mode: email is required when Client ID is not configured.'
                    });
                }
            } else {
                const ticket = await googleClient.verifyIdToken({
                    idToken: idToken,
                    audience: GOOGLE_WEB_CLIENT_ID,
                });
                const payload = ticket.getPayload();
                verifiedEmail = payload.email;
                verifiedName = payload.name;
            }
        }

        const sql = `
            SELECT u.*, r.name as roleName
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.email = ?
        `;
        let users = await query(sql, [verifiedEmail]);
        let user;

        if (users.length === 0) {
            const randomPassword = Math.random().toString(36).slice(-12);
            const hashedPassword = await bcrypt.hash(randomPassword, 10);
            const insertSql = 'INSERT INTO users (name, email, password, role_id) VALUES (?, ?, ?, 2)';
            const insertResult = await query(insertSql, [verifiedName || 'Traveler', verifiedEmail, hashedPassword, 2]);

            user = {
                id: insertResult.insertId,
                name: verifiedName || 'Traveler',
                email: verifiedEmail,
                roleName: 'User'
            };
        } else {
            user = users[0];
        }

        const token = createSession(user);

        return res.status(200).json({
            success: true,
            message: `Authentication Successful via ${provider}`,
            token: token,
            user: {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.roleName
            }
        });

    } catch (err) {
        console.error('Error during OAuth flow:', err);
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error during external authentication.'
        });
    }
});

module.exports = router;
