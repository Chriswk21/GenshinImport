const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { query } = require('../config/db');
const { createSession } = require('../utils/sessionStore');



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



router.post('/oauth', async (req, res) => {
    const { provider, oauthToken, email, name } = req.body;

    if (!provider || !oauthToken || !email) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: provider, oauthToken, and email are required.'
        });
    }

    try {
        console.log(`Processing External OAuth via [${provider}] for [${email}]...`);

        
        const sql = `
            SELECT u.*, r.name as roleName 
            FROM users u 
            JOIN roles r ON u.role_id = r.id 
            WHERE u.email = ?
        `;
        let users = await query(sql, [email]);
        let user;

        if (users.length === 0) {
            
            console.log(`New OAuth user. Automatically registering user [${email}] with 'User' role.`);
            
            
            const randomPassword = Math.random().toString(36).slice(-8);
            const hashedPassword = await bcrypt.hash(randomPassword, 10);
            
            const insertSql = 'INSERT INTO users (name, email, password, role_id) VALUES (?, ?, ?, 2)';
            const insertResult = await query(insertSql, [name || 'OAuth Traveler', email, hashedPassword]);
            
            user = {
                id: insertResult.insertId,
                name: name || 'OAuth Traveler',
                email: email,
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
