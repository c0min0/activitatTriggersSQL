USE mydb;

DELIMITER //
DROP PROCEDURE IF EXISTS spResetLleiDHondt; //

CREATE PROCEDURE spResetLleiDHondt()
BEGIN
	DROP TABLE IF EXISTS llei_dhondt;
    
	CREATE TABLE llei_dhondt (
		eleccio_id 		TINYINT,
		provincia_id	TINYINT,
		candidatura_id 	INT,
		num_escons 		TINYINT,
		CONSTRAINT pk_llei_dhont PRIMARY KEY (eleccio_id, provincia_id, candidatura_id)
	);
END //

DELIMITER //
DROP PROCEDURE IF EXISTS spCalcularLleiHontEleccionsProvincia; //

CREATE PROCEDURE spCalcularLleiHontEleccionsProvincia(IN pEleccioId TINYINT UNSIGNED, IN pProvinciaId TINYINT UNSIGNED)
BEGIN
	-- Declarem variables
	DECLARE fi_cursor	BOOLEAN DEFAULT false;
    DECLARE tmpCandidaturaId INT UNSIGNED;
    DECLARE tmpVots FLOAT;
    DECLARE vNumEscons TINYINT UNSIGNED;
    DECLARE vVotsMin FLOAT;
    DECLARE count TINYINT UNSIGNED DEFAULT 1;
    
    -- Declarem el cursor que serà el ranking de totes les divisions dels vots de les candidatures
    DECLARE cDivLleiDHondt CURSOR FOR
		SELECT candidatura_id, vots
			FROM tmpDivLleiDHondt
		ORDER BY vots DESC, divisio DESC
        LIMIT vNumEscons;
        
	-- Declarem el handler per gestionar errors
    DECLARE CONTINUE HANDLER FOR NOT FOUND
	BEGIN
		SET fi_cursor = true;
	END;
    
    -- Treiem possibles mals inputs
    IF (pEleccioId AND pProvinciaId) IS NOT NULL 
		AND pEleccioId IN (SELECT eleccio_id FROM eleccions) 
		AND pProvinciaId IN (SELECT provincia_id FROM provincies) THEN
    
		-- Obtenim el total d'escons de la província
		SET vNumEscons = (SELECT num_escons
							FROM provincies
						WHERE provincia_id = pProvinciaId);
                        
		-- Obtenim el mínim de vots per poder obtenir escons
        SET vVotsMin = (SELECT SUM(vots_valids)		
							FROM eleccions_municipis e
							INNER JOIN municipis m USING (municipi_id)
						WHERE m.provincia_id = pProvinciaId AND e.eleccio_id = pEleccioId) * 0.05;
        
		-- Creem la taula auxiliar per calcular els escons
		DROP TABLE IF EXISTS tmpDivLleiDHondt;
		CREATE TABLE tmpDivLleiDHondt (
			candidatura_id		INT UNSIGNED,
            divisio				TINYINT UNSIGNED,
			vots				FLOAT,
            CONSTRAINT pk_tmpDivLleiDHondt PRIMARY KEY (candidatura_id, divisio)
		);
        
        -- Generem totes les divisions a la taula auxiliar
        WHILE count <= vNumEscons DO
			INSERT INTO tmpDivLleiDHondt(candidatura_id, divisio, vots)
				SELECT candidatura_id, count, vots / count
					FROM vots_candidatures_prov v
					INNER JOIN candidatures c USING (candidatura_id)
				WHERE v.provincia_id = pProvinciaId 
					AND c.eleccio_id = pEleccioId
					AND v.vots >= vVotsMin;
                                
			SET count = count +1;
        END WHILE;
        
        SET count = 1;
        
        -- Reset a la taula llei_dhondt
        CALL spResetLleiDHondt();
											
	   -- Calculem els escons de cada candidatura
	   
	   -- Obrim el cursor
		OPEN cDivLleiDHondt;
		
		-- Fem el primer fetch
		FETCH cDivLleiDHondt INTO tmpCandidaturaId, tmpVots;
        
		-- Recorrem el ranking summant els escons fins que s'esgotin els escons
		WHILE (fi_cursor = false AND count <= vNumEscons) DO
			IF (SELECT candidatura_id FROM llei_dhondt WHERE candidatura_id = tmpCandidaturaId) IS NOT NULL THEN
				UPDATE llei_dhondt
					SET num_escons = num_escons + 1
				WHERE candidatura_id = tmpCandidaturaId;
                
			ELSE
				INSERT INTO llei_dhondt (eleccio_id, provincia_id, candidatura_id, num_escons)
				VALUES (pEleccioId, pProvinciaId, tmpCandidaturaId, 1);
                
			END IF;
            
            SET count = count +1;
            
            FETCH cDivLleiDHondt INTO tmpCandidaturaId, tmpVots;
            
	   END WHILE;
	   
	   CLOSE cDivLleiDHondt;
       
	ELSE
		-- Si no es troben resultats per als valors introduïts, buidem dades de la taula llei_dhondt per no confondre el resultat amb l'últim resultat obtingut
		CALL spResetLleiDHondt();
	END IF;
    
    SELECT * FROM mydb.llei_dhondt;
END //

