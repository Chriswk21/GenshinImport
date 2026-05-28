const express = require('express');
const router = express.Router();
const { query } = require('../config/db');
const { verifyToken, adminOnly } = require('../middleware/authMiddleware');



router.get('/', async (req, res) => {
    try {
        const sql = 'SELECT * FROM items';
        const items = await query(sql);
        
        
        return res.status(200).json({
            success: true,
            data: items
        });
    } catch (err) {
        console.error('Error fetching items:', err);
        return res.status(500).json({
            success: false,
            message: 'Error fetching Teyvat items.'
        });
    }
});



router.get('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const sql = 'SELECT * FROM items WHERE id = ?';
        const items = await query(sql, [id]);

        if (items.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Item not found.'
            });
        }

        return res.status(200).json({
            success: true,
            data: items[0]
        });
    } catch (err) {
        console.error(`Error fetching item details for ID ${id}:`, err);
        return res.status(500).json({
            success: false,
            message: 'Error fetching item details.'
        });
    }
});



router.post('/', verifyToken, adminOnly, async (req, res) => {
    const { name, type, description, stock, image, price } = req.body;

    
    if (!name || !type || !description || stock === undefined || !image || price === undefined) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: All fields (name, type, description, stock, image, price) are required.'
        });
    }

    if (parseInt(stock) < 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Item stock cannot be negative.'
        });
    }

    if (parseFloat(price) < 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Item price cannot be negative.'
        });
    }

    try {
        const sql = 'INSERT INTO items (name, type, description, stock, image, price) VALUES (?, ?, ?, ?, ?, ?)';
        const params = [name, type, description, parseInt(stock), image, parseFloat(price)];
        const result = await query(sql, params);

        return res.status(201).json({
            success: true,
            message: 'Teyvat item created successfully.',
            data: {
                id: result.insertId,
                name,
                type,
                description,
                stock: parseInt(stock),
                image,
                price: parseFloat(price)
            }
        });
    } catch (err) {
        console.error('Error creating item:', err);
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error while inserting new item.'
        });
    }
});



router.put('/:id', verifyToken, adminOnly, async (req, res) => {
    const { id } = req.params;
    const { name, type, description, stock, image, price } = req.body;

    
    if (!name || !type || !description || stock === undefined || !image || price === undefined) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: All fields are required.'
        });
    }

    if (parseInt(stock) < 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Item stock cannot be negative.'
        });
    }

    if (parseFloat(price) < 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Item price cannot be negative.'
        });
    }

    try {
        
        const checkSql = 'SELECT * FROM items WHERE id = ?';
        const items = await query(checkSql, [id]);
        if (items.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Item not found to update.'
            });
        }

        const sql = 'UPDATE items SET name=?, type=?, description=?, stock=?, image=?, price=? WHERE id=?';
        const params = [name, type, description, parseInt(stock), image, parseFloat(price), id];
        await query(sql, params);

        return res.status(200).json({
            success: true,
            message: 'Teyvat item updated successfully.',
            data: {
                id: parseInt(id),
                name,
                type,
                description,
                stock: parseInt(stock),
                image,
                price: parseFloat(price)
            }
        });
    } catch (err) {
        console.error(`Error updating item with ID ${id}:`, err);
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error while updating item.'
        });
    }
});



router.delete('/:id', verifyToken, adminOnly, async (req, res) => {
    const { id } = req.params;

    try {
        
        const checkSql = 'SELECT * FROM items WHERE id = ?';
        const items = await query(checkSql, [id]);
        if (items.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'Item not found to delete.'
            });
        }

        const sql = 'DELETE FROM items WHERE id = ?';
        await query(sql, [id]);

        return res.status(200).json({
            success: true,
            message: `Teyvat item ID ${id} deleted successfully.`
        });
    } catch (err) {
        console.error(`Error deleting item with ID ${id}:`, err);
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error while deleting item.'
        });
    }
});



router.post('/buy', verifyToken, async (req, res) => {
    const { cart } = req.body; 

    if (!cart || !Array.isArray(cart) || cart.length === 0) {
        return res.status(400).json({
            success: false,
            message: 'Validation Failure: Checkout cart is empty or invalid format.'
        });
    }

    try {
        
        for (const cartItem of cart) {
            const { id, quantity } = cartItem;

            if (!id || !quantity || parseInt(quantity) <= 0) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation Failure: Invalid quantity or item ID in cart.'
                });
            }

            const checkSql = 'SELECT * FROM items WHERE id = ?';
            const items = await query(checkSql, [id]);

            if (items.length === 0) {
                return res.status(404).json({
                    success: false,
                    message: `Item ID ${id} does not exist in inventory.`
                });
            }

            const dbItem = items[0];
            if (dbItem.stock < parseInt(quantity)) {
                return res.status(400).json({
                    success: false,
                    message: `Stock Shortage: "${dbItem.name}" has only ${dbItem.stock} items left. Requested: ${quantity}.`
                });
            }
        }

        
        for (const cartItem of cart) {
            const { id, quantity } = cartItem;
            const updateSql = 'UPDATE items SET stock = stock - ? WHERE id = ?';
            await query(updateSql, [parseInt(quantity), id]);
        }

        return res.status(200).json({
            success: true,
            message: 'Purchase completed successfully! Stock updated in Teyvat inventory.'
        });

    } catch (err) {
        console.error('Error during items purchase checkout:', err);
        return res.status(500).json({
            success: false,
            message: 'Internal Server Error during checkout transaction.'
        });
    }
});

module.exports = router;
