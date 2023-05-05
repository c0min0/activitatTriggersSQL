USE mydb;

DELIMITER // 
DROP PROCEDURE IF EXISTS spReinicialitzaVotsValids; //

CREATE PROCEDURE spReinicialitzaVotsValids(IN pEleccioId TINYINT UNSIGNED, IN pMunicipiId SMALLINT UNSIGNED)
BEGIN
	IF pMunicipiId IS NULL THEN
		CALL spReinicialitzaTotsVotsValids(pEleccioId);
    ELSE
		CALL spUpdVotsValids(pEleccioId, pMunicipiId);
    END IF;
END 
//

DELIMITER //
DROP PROCEDURE IF EXISTS spReinicialitzaTotsVotsValids; //

CREATE PROCEDURE spReinicialitzaTotsVotsValids(IN pEleccioId TINYINT UNSIGNED)
BEGIN
	-- Declarem variables
	DECLARE fi_cursor	BOOLEAN DEFAULT false;
    DECLARE tmpMunicipiId SMALLINT;
    
    -- Declarem el cursor
    DECLARE cEleccionsMunicipis CURSOR FOR
		SELECT municipi_id
			FROM eleccions_municipis
		WHERE eleccio_id = pEleccioId;
    
    -- Declarem el handler per gestionar errors
    DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
		SET fi_cursor = true;
	END;
    
    -- Obrim el cursor
    OPEN cEleccionsMunicipis;
    
    -- Fem el primer fetch
    FETCH cEleccionsMunicipis INTO tmpMunicipiId; -- tmpVotsValids;
    
    -- Recorrem la selecció del cursor actualitzant els valors desitjats
    WHILE (fi_cursor = false) DO 
		CALL spUpdVotsValids(pEleccioId, tmpMunicipiId);
        
        FETCH cEleccionsMunicipis INTO tmpMunicipiId;
   END WHILE;
   
   CLOSE cEleccionsMunicipis;
END //

DELIMITER //
DROP PROCEDURE IF EXISTS spUpdVotsValids; //
CREATE PROCEDURE spUpdVotsValids(IN pEleccioId TINYINT UNSIGNED, IN pMunicipiId SMALLINT UNSIGNED)
BEGIN
	UPDATE eleccions_municipis
		SET vots_valids = vots_candidatures + vots_blanc
	WHERE eleccio_id = pEleccioId AND municipi_id = pMunicipiId;
END //