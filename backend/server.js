const express = require('express');
const cors = require('cors');
const { initDb } = require('./config/db');


const authRouter = require('./routes/auth');
const itemsRouter = require('./routes/items');

const path = require('path');
const fs = require('fs');
const multer = require('multer');


const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}


const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        const ext = path.extname(file.originalname);
        cb(null, 'file-' + uniqueSuffix + ext);
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 } 
});

const app = express();
const PORT = process.env.PORT || 3000;


app.use('/uploads', express.static(uploadDir));


app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));


app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <title>Genshin Import API Portal</title>
            <style>
                body {
                    background-color: #0A0F1D;
                    color: #ECE5D8;
                    font-family: 'Cinzel', 'Inter', serif, sans-serif;
                    text-align: center;
                    padding: 50px;
                }
                .container {
                    border: 2px solid #D3BC8E;
                    border-radius: 12px;
                    padding: 30px;
                    max-width: 600px;
                    margin: 0 auto;
                    background: linear-gradient(135deg, #111827 0%, #030712 100%);
                    box-shadow: 0 8px 32px 0 rgba(211, 188, 142, 0.2);
                }
                h1 {
                    color: #D3BC8E;
                    font-size: 2.5rem;
                    margin-bottom: 10px;
                    letter-spacing: 2px;
                }
                p {
                    color: #A78B50;
                    font-size: 1.2rem;
                }
                .status {
                    background-color: rgba(58, 175, 169, 0.2);
                    border: 1px solid #3AAFA9;
                    color: #3AAFA9;
                    padding: 10px;
                    border-radius: 6px;
                    display: inline-block;
                    margin-top: 20px;
                    font-weight: bold;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>GENSIN IMPORT API</h1>
                <p>Divine Teyvat Artifacts & Weapons Store Back-End Server Portal</p>
                <div class="status">🟢 SERVER ONLINE & SECURED</div>
            </div>
        </body>
        </html>
    `);
});


app.use('/api/auth', authRouter);
app.use('/api/items', itemsRouter);


app.post('/api/items/upload', upload.single('image'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ success: false, message: 'No file uploaded.' });
    }
    
    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
    
    return res.status(200).json({
        success: true,
        imageUrl: imageUrl,
        filename: req.file.filename
    });
});


async function startServer() {
    await initDb();
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`==================================================`);
        console.log(`🚀 SERVER ACTIVE: Listening on http://localhost:${PORT}`);
        console.log(`🔒 SECURED: Bearer Token and Custom Middleware enabled`);
        console.log(`==================================================`);
    });
}

startServer();
