const crypto = require('crypto');

const activeSessions = new Map();

activeSessions.set('n8x7wfqtsrvxnvsm8dcz', {
    userId: 1,
    email: 'admin@genshin.com',
    roleName: 'Admin',
    name: 'Lumine Admin'
});

activeSessions.set('u8x7wfqtsrvxnvsm8dcuser', {
    userId: 2,
    email: 'user@genshin.com',
    roleName: 'User',
    name: 'Aether User'
});

function createSession(user) {
    const token = crypto.randomBytes(12).toString('hex');
    activeSessions.set(token, {
        userId: user.id,
        email: user.email,
        roleName: user.roleName,
        name: user.name
    });
    return token;
}

function getSession(token) {
    return activeSessions.get(token);
}

function destroySession(token) {
    return activeSessions.delete(token);
}

module.exports = {
    createSession,
    getSession,
    destroySession
};
