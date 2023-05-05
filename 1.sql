USE mydb;

DROP FUNCTION IF EXISTS spMunicipiNumVots;

DELIMITER // 
CREATE FUNCTION spMunicipiNumVots(pEleccioId TINYINT, pMunicipiId SMALLINT) RETURNS INT
	NOT DETERMINISTIC READS SQL DATA    
BEGIN
	DECLARE vRetorn INT;
    
	SET vRetorn = (SELECT vots_emesos
						FROM eleccions_municipis
					WHERE eleccio_id = pEleccioId AND municipi_id = pMunicipiId);
                    
	RETURN vRetorn;
END //

