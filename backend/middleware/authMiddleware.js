const { getSession } = require('../utils/sessionStore');

function verifyToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    
    if (!authHeader) {
        return res.status(401).json({ 
            success: false, 
            message: 'Access Denied: No Authorization header provided.' 
        });
    }

    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
        return res.status(401).json({ 
            success: false, 
            message: 'Access Denied: Invalid Authorization header format. Expected Bearer <token>' 
        });
    }

    const token = parts[1];
    const session = getSession(token);

    if (!session) {
        return res.status(401).json({ 
            success: false, 
            message: 'Access Denied: Session expired or invalid token.' 
        });
    }

    req.user = session;
    next();
}

function adminOnly(req, res, next) {
    if (!req.user || req.user.roleName !== 'Admin') {
        return res.status(403).json({ 
            success: false, 
            message: 'Forbidden: Access restricted to Admin role.' 
        });
    }
    next();
}

function userOnly(req, res, next) {
    if (!req.user || req.user.roleName !== 'User') {
        return res.status(403).json({ 
            success: false, 
            message: 'Forbidden: Access restricted to User role.' 
        });
    }
    next();
}

module.exports = {
    verifyToken,
    adminOnly,
    userOnly
};
