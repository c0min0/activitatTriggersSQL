USE mydb;

DELIMITER //
DROP PROCEDURE IF EXISTS spUpdVotsProv; //
CREATE PROCEDURE spUpdVotsProv(IN pCandidaturaId INT UNSIGNED, IN pMunicipiId SMALLINT UNSIGNED)
BEGIN
	DECLARE vProv TINYINT UNSIGNED;
    DECLARE vExistsRegistreProv BOOLEAN DEFAULT FALSE;
	DECLARE vVots INT UNSIGNED;
    
    -- Trobem la província del municipi
    SET vProv = (SELECT provincia_id
				 	FROM municipis
				 WHERE municipi_id = pMunicipiId);
	
    -- Mirem si ja existeix el registre de la província
	IF EXISTS (SELECT *
					FROM vots_candidatures_prov
			   WHERE candidatura_id = pCandidaturaId 
				AND provincia_id = vProv) THEN SET vExistsRegistreProv = TRUE;
	END IF;
    

	-- Calculem el total de vots de la província
    SET vVots = (SELECT SUM(vots)
					 FROM vots_candidatures_mun vm
                     INNER JOIN municipis m USING (municipi_id)
				 WHERE vm.candidatura_id = pCandidaturaId 
					 AND m.provincia_id = vProv);

	-- Si la província ja existeix a la taula vots_candidatures_prov
	IF vExistsRegistreProv THEN
    
		-- Si el total de vots és 0 borrem el registre
		IF vVots = 0 OR vVots IS NULL THEN
			DELETE FROM vots_candidatures_prov
			WHERE candidatura_id = pCandidaturaId 
			AND provincia_id = vProv;
            
        -- Si és més que 0 actualitzem els vots
		ELSE
			UPDATE vots_candidatures_prov
				SET vots = vVots
			WHERE candidatura_id = pCandidaturaId 
				AND provincia_id = vProv;
		END IF;
            
	ELSE
		-- Si no existeix el registre l'afegim
		INSERT INTO vots_candidatures_prov (provincia_id, candidatura_id, vots)
			VALUES (vProv, pCandidaturaId, vVots);	
            
    END IF;
END //

DELIMITER //
DROP TRIGGER IF EXISTS tgrUpdVotsProvWhenInsVotsMun; //
CREATE TRIGGER tgrUpdVotsProvWhenInsVotsMun AFTER INSERT
	ON vots_candidatures_mun FOR EACH ROW
BEGIN
	CALL spUpdVotsProv(NEW.candidatura_id, NEW.municipi_id);
END //

DELIMITER //
DROP TRIGGER IF EXISTS tgrUpdVotsProvWhenDelVotsMun; //
CREATE TRIGGER tgrUpdVotsProvWhenDelVotsMun AFTER DELETE
	ON vots_candidatures_mun FOR EACH ROW
BEGIN
	CALL spUpdVotsProv(OLD.candidatura_id, OLD.municipi_id);
END //

DELIMITER //
DROP TRIGGER IF EXISTS tgrUpdVotsProvWhenUpdVotsMun; //
CREATE TRIGGER tgrUpdVotsProvWhenUpdVotsMun AFTER UPDATE
	ON vots_candidatures_mun FOR EACH ROW
BEGIN
	CALL spUpdVotsProv(OLD.candidatura_id, OLD.municipi_id);
    CALL spUpdVotsProv(NEW.candidatura_id, NEW.municipi_id);
END //