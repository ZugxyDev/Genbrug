CREATE TABLE IF NOT EXISTS genbrug (
    id INT AUTO_INCREMENT PRIMARY KEY,
    level INT NOT NULL,
    xp INT NOT NULL,
    boost DECIMAL(3,2) NOT NULL
);