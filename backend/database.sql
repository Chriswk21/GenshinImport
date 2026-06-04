CREATE DATABASE IF NOT EXISTS genshin_import;
USE genshin_import;

DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO roles (name) VALUES ('Admin'), ('User');

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);

INSERT INTO users (name, email, password, role_id) VALUES
('Lumine Admin', 'admin@genshin.com', '$2a$10$1qnV3y6wtn5T8ZkyL6bQzuDC0ZJ655sgc76OjhUBDxqY/Wua4pduu', 1),
('Aether User', 'user@genshin.com', '$2a$10$r0.5rJ1zgX/iFyUKxV6HwupFvyIm9cVBKX1YqXS7amM7vyIBnXcXa', 2);

CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    stock INT NOT NULL CHECK (stock >= 0),
    image VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0)
);

INSERT INTO items (name, type, description, stock, image, price) VALUES
('Celestial Azure Wand', 'Weapon', 'A mystical azure catalyst forged from high-purity crystal marrow and stardust. It channels volatile elemental energies into powerful arcane blasts, serving as the ultimate wand for Teyvat''s grand mages.', 10, 'assets/image1.jpg', 1200.00),
('Blade of Despair', 'Weapon', 'A colossal, legendary greatsword radiating a vivid green aura of pure cosmic might. Forged in the depths of Teyvat''s ancient chasm, its massive blade unleashes unmatched kinetic power, capable of sundering mountains and shattering any defense.', 5, 'assets/image2.jpg', 1500.00),
('Dominance Ice', 'Artifact', 'A divine crystalline shield crafted from everlasting permafrost by the gods of Teyvat. It radiates an absolute zero temperature field that freezes incoming attacks, granting its wielder ultimate defensive capability and impenetrable protection.', 50, 'assets/image3.jpg', 300.00),
('Windtalker', 'Weapon', 'A sleek, masterfully balanced speed sword imbued with the blessings of the Anemo Archon. Its aerodynamic edge slices through the wind, granting its wielder supernatural swiftness and lightning-fast strike velocities.', 40, 'assets/image4.jpg', 350.00),
('Sea Halberd', 'Weapon', 'A cursed marine halberd forged from abyssal alloy. Its jagged blade inflicts deep wounds that nullify any form of biological or elemental healing, making it the perfect anti-healer weapon to neutralize Teyvat''s most resilient adversaries.', 8, 'assets/image5.jpg', 1100.00),
('Rose Gold Meteor', 'Weapon', 'An exquisite sword crafted from rare cosmic stardust and rose-tinted gold. When the wielder\'s vitality drops, the blade instantly detonates a protective celestial barrier, absorbing immense damage with a spectacular starfield shield.', 30, 'assets/image6.jpg', 280.00),
('Antique Cuirass', 'Artifact', 'An ancient chestplate forged from sacred metals. Its presence weakens the offensive will of attackers, reducing the impact of their strikes and protecting the wielder.', 25, 'assets/image7.jpg', 920.00),
('Guardian Helmet', 'Artifact', 'A majestic helmet imbued with eternal life force. It steadily restores the wearer\'s vitality over time, making them an indomitable guardian of the battlefield.', 15, 'assets/image8.jpg', 1000.00),
('Athena\'s Shield', 'Artifact', 'A sacred shield blessed by the goddess of wisdom. When struck by powerful magic, it conjures a glowing protective dome that absorbs incoming spell damage.', 20, 'assets/image9.jpg', 900.00);
