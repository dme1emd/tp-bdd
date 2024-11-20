CREATE TABLE produits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,        
    stock INT NOT NULL              
);

CREATE TABLE commandes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,            
    date_commande DATE NOT NULL        
);


CREATE TABLE produits_commandes (
    id INT AUTO_INCREMENT PRIMARY KEY, 
    commande_id INT NOT NULL,          
    produit_id INT NOT NULL,           
    quantite INT NOT NULL,             
    FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE CASCADE, 
    FOREIGN KEY (produit_id) REFERENCES produits(id) ON DELETE CASCADE   
);




BEGIN TRANSACTION;

SELECT p.id, p.nom, p.stock, pc.quantite
FROM produits p
JOIN produits_commandes pc ON p.id = pc.produit_id
WHERE pc.commande_id = :commande_id
AND p.stock < pc.quantite;

UPDATE produits
SET stock = stock - pc.quantite
FROM produits_commandes pc
WHERE produits.id = pc.produit_id
AND pc.commande_id = :commande_id;

UPDATE commandes
SET statut = 'validée'
WHERE id = :commande_id;

COMMIT;


SELECT stock
FROM produits
WHERE id = :produit_id
FOR UPDATE;
INSERT INTO produits (id, nom, stock)
VALUES 
    (1, 'Produit A', 10),
    (2, 'Produit B', 20),
    (3, 'Produit C', 30);
INSERT INTO commandes (id, client_id, date_commande)
VALUES 
    (1, 1, '2022-01-01'),
    (2, 2, '2022-01-02');
BEGIN;

-- Exemple : Commande pour "Produit A" (id: 1), quantité commandée = 5
-- Vérifier si le stock est suffisant
DO $$
BEGIN
    IF (SELECT stock FROM produits WHERE id = 1) >= 5 THEN
        -- Mettre à jour le stock
        UPDATE produits
        SET stock = stock - 5
        WHERE id = 1;

        -- Ajouter l'enregistrement dans produits_commandes
        INSERT INTO produits_commandes (commande_id, produit_id, quantite)
        VALUES (1, 1, 5);
    ELSE
        RAISE EXCEPTION 'Stock insuffisant pour le produit 1';
    END IF;
END;
$$;

COMMIT;
