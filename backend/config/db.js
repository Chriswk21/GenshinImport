const mysql = require('mysql2/promise');


const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'genshin_import',
    port: process.env.DB_PORT || 3306
};

let pool = null;
let useMockDb = false;


const mockDb = {
    roles: [
        { id: 1, name: 'Admin' },
        { id: 2, name: 'User' }
    ],
    users: [
        { 
            id: 1, 
            name: 'Lumine Admin', 
            email: 'admin@genshin.com', 
            password: '$2a$10$1qnV3y6wtn5T8ZkyL6bQzuDC0ZJ655sgc76OjhUBDxqY/Wua4pduu', 
            role_id: 1 
        },
        { 
            id: 2, 
            name: 'Aether User', 
            email: 'user@genshin.com', 
            password: '$2a$10$r0.5rJ1zgX/iFyUKxV6HwupFvyIm9cVBKX1YqXS7amM7vyIBnXcXa', 
            role_id: 2 
        }
    ],
    items: [
        {
            id: 1,
            name: 'Celestial Azure Wand',
            type: 'Weapon',
            description: 'A mystical azure catalyst forged from high-purity crystal marrow and stardust. It channels volatile elemental energies into powerful arcane blasts, serving as the ultimate wand for Teyvat\'s grand mages.',
            stock: 10,
            image: 'assets/image1.jpg',
            price: 1200.00
        },
        {
            id: 2,
            name: 'Blade of Despair',
            type: 'Weapon',
            description: 'A colossal, legendary greatsword radiating a vivid green aura of pure cosmic might. Forged in the depths of Teyvat\'s ancient chasm, its massive blade unleashes unmatched kinetic power, capable of sundering mountains and shattering any defense.',
            stock: 5,
            image: 'assets/image2.jpg',
            price: 1500.00
        },
        {
            id: 3,
            name: 'Dominance Ice',
            type: 'Artifact',
            description: 'A divine crystalline shield crafted from everlasting permafrost by the gods of Teyvat. It radiates an absolute zero temperature field that freezes incoming attacks, granting its wielder ultimate defensive capability and impenetrable protection.',
            stock: 50,
            image: 'assets/image3.jpg',
            price: 300.00
        },
        {
            id: 4,
            name: 'Windtalker',
            type: 'Weapon',
            description: 'A sleek, masterfully balanced speed sword imbued with the blessings of the Anemo Archon. Its aerodynamic edge slices through the wind, granting its wielder supernatural swiftness and lightning-fast strike velocities.',
            stock: 40,
            image: 'assets/image4.jpg',
            price: 350.00
        },
        {
            id: 5,
            name: 'Sea Halberd',
            type: 'Weapon',
            description: 'A cursed marine halberd forged from abyssal alloy. Its jagged blade inflicts deep wounds that nullify any form of biological or elemental healing, making it the perfect anti-healer weapon to neutralize Teyvat\'s most resilient adversaries.',
            stock: 8,
            image: 'assets/image5.jpg',
            price: 1100.00
        },
        {
            id: 6,
            name: 'Rose Gold Meteor',
            type: 'Weapon',
            description: 'An exquisite sword crafted from rare cosmic stardust and rose-tinted gold. When the wielder\'s vitality drops, the blade instantly detonates a protective celestial barrier, absorbing immense damage with a spectacular starfield shield.',
            stock: 30,
            image: 'assets/image6.jpg',
            price: 280.00
        }
    ]
};

async function initDb() {
    try {
        pool = mysql.createPool({
            ...dbConfig,
            waitForConnections: true,
            connectionLimit: 10,
            queueLimit: 0
        });

        
        const connection = await pool.getConnection();
        console.log('--------------------------------------------------');
        console.log('🟢 SUCCESS: Connected to MySQL database "genshin_import".');
        console.log('--------------------------------------------------');
        connection.release();
    } catch (err) {
        console.log('--------------------------------------------------');
        console.log('⚠️  WARNING: Could not connect to MySQL database on localhost:3306.');
        console.log(`Reason: ${err.message}`);
        console.log('🟢 FALLBACK: Switching to In-Memory Mock Database!');
        console.log('Application will operate perfectly in mock mode.');
        console.log('To use live MySQL, ensure XAMPP MySQL is active, and "database.sql" is executed.');
        console.log('--------------------------------------------------');
        useMockDb = true;
    }
}


async function query(sql, params = []) {
    if (useMockDb) {
        return handleMockQuery(sql, params);
    }
    try {
        const [results] = await pool.query(sql, params);
        return results;
    } catch (err) {
        console.error(`Database Query Error: ${err.message}`);
        throw err;
    }
}


function handleMockQuery(sql, params) {
    const cleanSql = sql.trim().toLowerCase().replace(/\s+/g, ' ');
    
    
    if (cleanSql.includes('select u.*, r.name as rolename from users u join roles r')) {
        const email = params[0];
        const user = mockDb.users.find(u => u.email === email);
        if (!user) return [];
        const role = mockDb.roles.find(r => r.id === user.role_id);
        return [{
            ...user,
            roleName: role ? role.name : 'User'
        }];
    }



    
    if (cleanSql.includes('select * from items') && !cleanSql.includes('where id =')) {
        return mockDb.items;
    }

    
    if (cleanSql.includes('select * from items where id =')) {
        const id = parseInt(params[0]);
        const item = mockDb.items.find(i => i.id === id);
        return item ? [item] : [];
    }

    
    if (cleanSql.startsWith('insert into items')) {
        
        const newItem = {
            id: mockDb.items.length > 0 ? Math.max(...mockDb.items.map(i => i.id)) + 1 : 1,
            name: params[0],
            type: params[1],
            description: params[2],
            stock: parseInt(params[3]),
            image: params[4],
            price: parseFloat(params[5])
        };
        mockDb.items.push(newItem);
        return { insertId: newItem.id };
    }

    
    if (cleanSql.startsWith('update items')) {
        
        
        if (cleanSql.includes('set stock = stock -')) {
            const qty = parseInt(params[0]);
            const id = parseInt(params[1]);
            const item = mockDb.items.find(i => i.id === id);
            if (item) {
                item.stock -= qty;
                return { affectedRows: 1 };
            }
            return { affectedRows: 0 };
        } else {
            const id = parseInt(params[6]);
            const itemIndex = mockDb.items.findIndex(i => i.id === id);
            if (itemIndex !== -1) {
                mockDb.items[itemIndex] = {
                    id,
                    name: params[0],
                    type: params[1],
                    description: params[2],
                    stock: parseInt(params[3]),
                    image: params[4],
                    price: parseFloat(params[5])
                };
                return { affectedRows: 1 };
            }
            return { affectedRows: 0 };
        }
    }

    
    if (cleanSql.startsWith('delete from items')) {
        const id = parseInt(params[0]);
        const itemIndex = mockDb.items.findIndex(i => i.id === id);
        if (itemIndex !== -1) {
            mockDb.items.splice(itemIndex, 1);
            return { affectedRows: 1 };
        }
        return { affectedRows: 0 };
    }

    
    return [];
}

module.exports = {
    initDb,
    query,
    isMock: () => useMockDb
};
