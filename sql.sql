USE `essentialmode`;

CREATE TABLE weed (
	ID int(10) NOT NULL AUTO_INCREMENT,
	Spot int(10) NOT NULL,
	Timer int(10) NOT NULL,
	Status int(10) NOT NULL,
	Ready int(10) NOT NULL,
	Water int(10) NOT NULL,
	Fertilizer int(10) NOT NULL,
	Quality int(10) NOT NULL,
	QualityCounter int(10) NOT NULL,
	PRIMARY KEY (ID)
);

INSERT INTO `items` (`name`, `label`, `limit`) VALUES
	('cannabis', 'Cannabis seed', 10),
	('marijuana', 'Marijuana', 60),
	('acqua', 'Water For Plants', 5),
	('fertilizzante', 'Fertilizzante', 5)
;
