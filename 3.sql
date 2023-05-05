USE mydb;

DELIMITER //
DROP PROCEDURE IF EXISTS spUpdVotsProv; //
CREATE PROCEDURE spUpdVotsProv(IN pCandidaturaId INT UNSIGNED, IN pMunicipiId SMALLINT UNSIGNED, IN pVots INT)
BEGIN
	UPDATE vots_candidatures_prov
		SET vots = vots + pVots
	WHERE candidatura_id = pCandidaturaId 
		AND provincia_id = (SELECT provincia_id
								FROM municipis
							WHERE municipi_id = pMunicipiId);
END //

DELIMITER //
DROP TRIGGER IF EXISTS tgrUpdVotsProvWhenInsVotsMun; //
CREATE TRIGGER tgrUpdVotsProvWhenInsVotsMun AFTER INSERT
	ON vots_candidatures_mun FOR EACH ROW
BEGIN
	CALL spUpdVotsProv(NEW.candidatura_id, NEW.municipi_id, NEW.vots);
END //

DELIMITER //
DROP TRIGGER IF EXISTS tgrUpdVotsProvWhenDelVotsMun; //
CREATE TRIGGER tgrUpdVotsProvWhenDelVotsMun AFTER DELETE
	ON vots_candidatures_mun FOR EACH ROW
BEGIN
	CALL spUpdVotsProv(OLD.candidatura_id, OLD.municipi_id, -OLD.vots);
END //

DELIMITER //
DROP TRIGGER IF EXISTS tgrUpdVotsProvWhenUpdVotsMun; //
CREATE TRIGGER tgrUpdVotsProvWhenUpdVotsMun AFTER UPDATE
	ON vots_candidatures_mun FOR EACH ROW
BEGIN
	CALL spUpdVotsProv(OLD.candidatura_id, OLD.municipi_id, -OLD.vots);
    CALL spUpdVotsProv(NEW.candidatura_id, NEW.municipi_id, NEW.vots);
END //