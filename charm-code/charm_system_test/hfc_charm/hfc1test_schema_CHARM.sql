SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `hfc1test` ;
USE `hfc1test`;

-- -----------------------------------------------------
-- Table `hfc1test`.`FRC_Info`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`FRC_Info` (
  `ID_FRC_INFO` INT(11) NOT NULL AUTO_INCREMENT ,
  `INSTITUT` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL COMMENT 'Institute responsible for running the FR code' ,
  `CODE` VARCHAR(100) CHARACTER SET 'latin1' NOT NULL COMMENT 'Name of the FR code' ,
  `VERSION` VARCHAR(50) CHARACTER SET 'latin1' NOT NULL COMMENT 'Version of the FR code' ,
  `FEATURE_NAME` VARCHAR(100) CHARACTER SET 'latin1' NOT NULL COMMENT 'Features detected' ,
  `CONTACT` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL COMMENT 'Person responsible for running the FR code' ,
  `REFERENCE` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL COMMENT 'Any document or article that describes the fr code' ,
  PRIMARY KEY (`ID_FRC_INFO`) )
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `hfc1test`.`OBSERVATORY`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`OBSERVATORY` (
  `ID_OBSERVATORY` INT(11) NOT NULL AUTO_INCREMENT ,
  `OBSERVAT` VARCHAR(255) CHARACTER SET 'latin1' NOT NULL ,
  `INSTRUME` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL ,
  `TELESCOP` VARCHAR(150) CHARACTER SET 'latin1' NOT NULL ,
  `UNITS` VARCHAR(100) CHARACTER SET 'latin1' NOT NULL ,
  `WAVEMIN` FLOAT NULL DEFAULT NULL ,
  `WAVEMAX` FLOAT NULL DEFAULT NULL ,
  `WAVENAME` VARCHAR(50) CHARACTER SET 'latin1' NULL DEFAULT NULL ,
  `WAVEUNIT` VARCHAR(10) NULL DEFAULT NULL ,
  `SPECTRAL_NAME` VARCHAR(100) CHARACTER SET 'latin1' NULL DEFAULT NULL ,
  `OBS_TYPE` VARCHAR(100) CHARACTER SET 'latin1' NULL DEFAULT NULL ,
  `COMMENT` TEXT CHARACTER SET 'latin1' NULL DEFAULT NULL ,
  PRIMARY KEY (`ID_OBSERVATORY`) )
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `hfc1test`.`OBSERVATIONS`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`OBSERVATIONS` (
  `ID_OBSERVATIONS` INT(11) NOT NULL AUTO_INCREMENT ,
  `OBSERVATORY_ID` INT(11) NOT NULL ,
  `DATE_OBS` DATETIME NOT NULL ,
  `DATE_END` DATETIME NOT NULL ,
  `JDINT` INT(11) NOT NULL COMMENT 'Julian day of the observation, integer part' ,
  `JDFRAC` DOUBLE NOT NULL COMMENT 'Julian day of the observation, fraction part' ,
  `EXP_TIME` FLOAT NULL DEFAULT NULL COMMENT 'Exposure time (if available), in seconds and fraction of s' ,
  `C_ROTATION` INT(7) NOT NULL COMMENT 'Carrington rotation' ,
  `BSCALE` DOUBLE NULL DEFAULT NULL COMMENT 'as extracted from the header' ,
  `BZERO` DOUBLE NULL DEFAULT NULL COMMENT 'As extracted from the header' ,
  `BITPIX` INT(3) NOT NULL COMMENT 'Coding of the original image' ,
  `NAXIS1` INT(6) NOT NULL COMMENT 'First dimension of the original image (X)' ,
  `NAXIS2` INT(6) NOT NULL COMMENT 'Second dimension of the original image (Y)' ,
  `R_SUN` DOUBLE NOT NULL COMMENT 'Radius of the Sun in pixels' ,
  `CENTER_X` DOUBLE NOT NULL COMMENT 'X coordinate of Sun centre in pixels' ,
  `CENTER_Y` DOUBLE NOT NULL COMMENT 'Y coordinate of Sun centre in pixels' ,
  `CDELT1` DOUBLE NOT NULL COMMENT 'Spatial scale of the original observation (X axis) (in arsec)' ,
  `CDELT2` DOUBLE NOT NULL COMMENT 'Spatial scale of the original observation (Y axis) (in arsec)' ,
  `QUALITY` VARCHAR(20) NULL DEFAULT NULL COMMENT 'Quality of the original image (in terms of processing)' ,
  `FILENAME` VARCHAR(100) NOT NULL COMMENT 'Name of the orignal file' ,
  `DATE_OBS_STRING` VARCHAR(150) NOT NULL ,
  `DATE_END_STRING` VARCHAR(150) NOT NULL ,
  `COMMENT` TEXT NOT NULL COMMENT 'As extracted from the header' ,
  `LOC_FILENAME` VARCHAR(200) NOT NULL ,
  `ID2` INT(11) NULL DEFAULT NULL ,
/*  `URL` VARCHAR(200) NOT NULL ,*/
  PRIMARY KEY USING BTREE (`ID_OBSERVATIONS`) ,
  UNIQUE INDEX `FILENAME` (`FILENAME` ASC) ,
  INDEX `new_fk_constraint` (`OBSERVATORY_ID` ASC) ,
  CONSTRAINT `new_fk_constraint`
    FOREIGN KEY (`ObservATORY_ID` )
    REFERENCES `hfc1test`.`OBSERVATORY` (`ID_OBSERVATORY` ))
ENGINE = InnoDB
AUTO_INCREMENT = 0
DEFAULT CHARACTER SET = utf8;



-- -----------------------------------------------------
-- Table `hfc1test`.`CHGROUPS`  (CHARM)
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`CHGROUPS` (
  `ID_CHGROUPS` INT(11) NOT NULL AUTO_INCREMENT ,
  `CH_NUMS` VARCHAR(150) NOT NULL COMMENT 'CHs belonging to group numbered as in image',
  `BR_X0_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in arcsec' ,
  `BR_Y0_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in arcsec' ,
  `BR_X1_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in arcsec' ,
  `BR_Y1_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in arcsec' ,
  `BR_X2_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in arcsec' ,
  `BR_Y2_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in arcsec' ,
  `BR_X3_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in arcsec' ,
  `BR_Y3_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in arcsec' ,
  `BR_X0_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in pixels' ,
  `BR_Y0_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in pixels' ,
  `BR_X1_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in pixels' ,
  `BR_Y1_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in pixels' ,
  `BR_X2_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in pixels' ,
  `BR_Y2_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in pixels' ,
  `BR_X3_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in pixels' ,
  `BR_Y3_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in pixels' ,
  `BR_HG_LONG0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South East most point in degrees' ,
  `BR_HG_LAT0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South East most point in degrees' ,
  `BR_HG_LONG1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North East most point in degrees' ,
  `BR_HG_LAT1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North East most point in degrees' ,
  `BR_HG_LONG2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South West most point in degrees' ,
  `BR_HG_LAT2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South West most point in degrees' ,
  `BR_HG_LONG3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North West most point in degrees' ,
  `BR_HG_LAT3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North West most point in degrees' ,
  `BR_CARR_LONG0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South East most point in degrees' ,
  `BR_CARR_LAT0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South East most point in degrees' ,
  `BR_CARR_LONG1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North East most point in degrees' ,
  `BR_CARR_LAT1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North East most point in degrees' ,
  `BR_CARR_LONG2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South West most point in degrees' ,
  `BR_CARR_LAT2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South West most point in degrees' ,
  `BR_CARR_LONG3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North West most point in degrees' ,
  `BR_CARR_LAT3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North West most point in degrees' ,
  `GROUP_X_ARCSEC`  FLOAT  NOT NULL COMMENT 'X Heliocentric coordinates of the CH group gravity centre in arcsec' ,
  `GROUP_Y_ARCSEC`  FLOAT  NOT NULL COMMENT 'Y Heliocentric coordinates of the CH group gravity centre in arcsec' ,
  `GROUP_X_PIX`  FLOAT  NOT NULL COMMENT 'X image coordinates of the CH group gravity center in pixel' ,
  `GROUP_Y_PIX`  FLOAT  NOT NULL COMMENT 'Y image coordinates of the CH group gravity center in pixel' ,
  `GROUP_HG_LONG_DEG`  FLOAT  NOT NULL COMMENT 'Heliographic longitude of the CH group Gravity centre in degrees' ,
  `GROUP_HG_LAT_DEG`  FLOAT  NOT NULL COMMENT 'Heliographic latitude of the CH group Gravity centre in degrees' ,
  `GROUP_CARR_LONG_DEG`  FLOAT  NOT NULL COMMENT 'Carrington longitude of the CH group gravity centre in degrees' ,
  `GROUP_CARR_LAT_DEG`  FLOAT  NOT NULL COMMENT 'Carrington latitude of the CH group gravity centre in degrees' ,
  `GROUP_WIDTH_X_ARCSEC` DOUBLE NOT NULL COMMENT 'X width of the CH group in HC arcsec',
  `GROUP_WIDTH_Y_ARCSEC` DOUBLE NOT NULL COMMENT 'Y width of the CH group in HC arcsec',
  `GROUP_WIDTH_X_PIX` DOUBLE NOT NULL COMMENT 'X width of the CH group in image pixels',
  `GROUP_WIDTH_Y_PIX` DOUBLE NOT NULL COMMENT 'Y width of the CH group in image pixels',
  `GROUP_WIDTH_HG_LONG_DEG` DOUBLE NOT NULL COMMENT 'Longitude width of the CH group in HG degrees',
  `GROUP_WIDTH_HG_LAT_DEG` DOUBLE NOT NULL COMMENT 'Latitude width of the CH group in HG degrees',
  `GROUP_WIDTH_CARR_LONG_DEG` DOUBLE NOT NULL COMMENT 'Longitude width of the CH group in Carrington degrees',
  `GROUP_WIDTH_CARR_LAT_DEG` DOUBLE NOT NULL COMMENT 'Latitude width of the CH group in Carrington degrees',
  `GROUP_AREA_PIX` INT(11) NOT NULL COMMENT 'Number of pixels included in the feature group' ,
  `GROUP_AREA_MM` FLOAT NOT NULL COMMENT 'Area in Mm2 of the feature group' ,
  `GROUP_AREA_DEG2` FLOAT NOT NULL COMMENT 'Area of the group in square degrees' ,
  `GROUP_MEAN_BZ` FLOAT NOT NULL COMMENT 'Feature mean line-of-sight magnetic field in Gauss' ,
  PRIMARY KEY (`ID_CHGROUPS`) )
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;
/*ROW_FORMAT = DYNAMIC;*/

-- -----------------------------------------------------
-- Table `hfc1test`.`CORONALHOLES` (CHARM)
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `hfc1test`.`CORONALHOLES` (
  `ID_CORONALHOLES` INT(11) NOT NULL AUTO_INCREMENT ,
  `CHGROUPS_ID` INT(11) NOT NULL COMMENT 'Pointing to group number',
  `IMAGE_ID` INT(11) NOT NULL COMMENT 'Number on the daily image',
  `IMAGE_GROUP_ID` INT(11) NOT NULL COMMENT 'Group number on the daily image',
  `FRC_INFO_ID` INT(11) NOT NULL COMMENT 'Ref. to FR code information' ,
  `OBSERVATION_ID_EIT` INT(11) NOT NULL COMMENT  'Pointing to observation in EIT' ,
  `OBSERVATION_ID_MDI` INT(11) NOT NULL COMMENT  'Pointing to observation in MDI' ,
  `RUN_DATE` DATETIME NOT NULL COMMENT 'Date when FR code was run' ,
  `OBS_DATE` DATETIME NOT NULL COMMENT 'Date when CH was observed' ,
  `FEAT_THRESHOLD` DOUBLE NOT NULL COMMENT 'Threshold value used on the image',
  `BR_X0_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in arcsec' ,
  `BR_Y0_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in arcsec' ,
  `BR_X1_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in arcsec' ,
  `BR_Y1_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in arcsec' ,
  `BR_X2_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in arcsec' ,
  `BR_Y2_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in arcsec' ,
  `BR_X3_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in arcsec' ,
  `BR_Y3_ARCSEC`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in arcsec' ,
  `BR_X0_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in pixels' ,
  `BR_Y0_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South East most point in pixels' ,
  `BR_X1_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in pixels' ,
  `BR_Y1_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North East most point in pixels' ,
  `BR_X2_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in pixels' ,
  `BR_Y2_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate South West most point in pixels' ,
  `BR_X3_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in pixels' ,
  `BR_Y3_PIX`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliocentric coordinate North West most point in pixels' ,
  `BR_HG_LONG0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South East most point in degrees' ,
  `BR_HG_LAT0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South East most point in degrees' ,
  `BR_HG_LONG1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North East most point in degrees' ,
  `BR_HG_LAT1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North East most point in degrees' ,
  `BR_HG_LONG2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South West most point in degrees' ,
  `BR_HG_LAT2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate South West most point in degrees' ,
  `BR_HG_LONG3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North West most point in degrees' ,
  `BR_HG_LAT3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle heliographic coordinate North West most point in degrees' ,
  `BR_CARR_LONG0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South East most point in degrees' ,
  `BR_CARR_LAT0_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South East most point in degrees' ,
  `BR_CARR_LONG1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North East most point in degrees' ,
  `BR_CARR_LAT1_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North East most point in degrees' ,
  `BR_CARR_LONG2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South West most point in degrees' ,
  `BR_CARR_LAT2_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate South West most point in degrees' ,
  `BR_CARR_LONG3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North West most point in degrees' ,
  `BR_CARR_LAT3_DEG`  FLOAT  NOT NULL COMMENT 'Bounding rectangle Carrington coordinate North West most point in degrees' ,
  `FEAT_X_ARCSEC`  FLOAT NOT NULL COMMENT 'X Heliocentric coordinates of the CH gravity centre in arcsec' ,
  `FEAT_Y_ARCSEC`  FLOAT NOT NULL COMMENT 'Y Heliocentric coordinates of the CH gravity centre in arcsec' ,
  `FEAT_X_PIX`  FLOAT NOT NULL COMMENT 'X image coordinates of the CH gravity centre in arcsec' ,
  `FEAT_Y_PIX`  FLOAT NOT NULL COMMENT 'Y image coordinates of the CH gravity centre in arcsec' ,
  `FEAT_HG_LONG_DEG`  FLOAT NOT NULL COMMENT 'Heliographic longitude of the CH gravity centre in arcsec' ,
  `FEAT_HG_LAT_DEG`  FLOAT NOT NULL COMMENT 'Heliographic latitude of the CH gravity centre in arcsec' ,
  `FEAT_CARR_LONG_DEG`  FLOAT NOT NULL COMMENT 'Carrington longitude of the CH gravity centre in arcsec' ,
  `FEAT_CARR_LAT_DEG`  FLOAT NOT NULL COMMENT 'Carrington latitude of the CH gravity centre in arcsec' ,
  `FEAT_WIDTH_X_ARCSEC`  FLOAT NOT NULL COMMENT 'X width of the CH in HC arcsec' ,
  `FEAT_WIDTH_Y_ARCSEC`  FLOAT NOT NULL COMMENT 'Y width of the CH in HC arcsec' ,
  `FEAT_WIDTH_X_PIX`  FLOAT NOT NULL COMMENT 'X width of the CH in image pixels' ,
  `FEAT_WIDTH_Y_PIX`  FLOAT NOT NULL COMMENT 'Y width of the CH in image pixels' ,
  `FEAT_WIDTH_HG_LONG_DEG`  FLOAT NOT NULL COMMENT 'Longitude width of the CH in HG deg' ,
  `FEAT_WIDTH_HG_LAT_DEG`  FLOAT NOT NULL COMMENT 'Latitude width of the CH in HG deg' ,
  `FEAT_WIDTH_CARR_LONG_DEG`  FLOAT NOT NULL COMMENT 'Longitude width of the CH in Carrington deg' ,
  `FEAT_WIDTH_CARR_LAT_DEG`  FLOAT NOT NULL COMMENT 'Latitude width of the CH in Carrington deg' ,
  `FEAT_AREA_PIX` INT(11) NOT NULL COMMENT 'Number of pixels included in the feature' ,
  `FEAT_AREA_MM` FLOAT NOT NULL COMMENT 'Area in Mm2 of the feature' ,
  `FEAT_AREA_DEG2` FLOAT NOT NULL COMMENT 'Area of the feature in square degrees' ,
  `FEAT_MIN_INT` FLOAT NOT NULL COMMENT 'Feature min. value, in units of the original observation' ,
  `FEAT_MAX_INT` FLOAT NOT NULL COMMENT 'Feature max. value, in units of the original observation' ,
  `FEAT_MEAN_INT` FLOAT NOT NULL COMMENT 'Feature mean intensity value in the units of the original obs.' ,
  `FEAT_MEAN2QSUN` DOUBLE NOT NULL COMMENT 'Mean of the feature to QS instensity ratio' ,
  `FEAT_MIN_BZ` FLOAT NOT NULL COMMENT 'Feature min. line-of-sight magnetic field in Gauss' ,
  `FEAT_MAX_BZ` FLOAT NOT NULL COMMENT 'Feature max. line-of-sight magnetic field in Gauss' ,
  `FEAT_MEAN_BZ` FLOAT NOT NULL COMMENT 'Feature mean line-of-sight magnetic field in Gauss' ,
  `FEAT_SKEW_BZ` DOUBLE NOT NULL COMMENT 'Feature skewness of the line-of-sight magnetic field in Gaus' ,
  `ENC_MET` VARCHAR(50) NOT NULL COMMENT 'Encoding method (raster, chain code, none...)' ,
  `CC_X_PIX` INT(11) NOT NULL COMMENT 'X coordinate of chain code start position in pixels' ,
  `CC_Y_PIX` INT(11) NOT NULL COMMENT 'Y coordinate of chain code start position in pixels' , 
  `CC_X_ARCSEC` FLOAT NOT NULL COMMENT 'X coordinate of chain code start position in arcsec' ,
  `CC_Y_ARCSEC` FLOAT NOT NULL COMMENT 'Y coordinate of chain code start position in arcsec' , 
  `CC` TEXT NOT NULL COMMENT 'Boundary chain code' ,
  `CC_LENGTH` INT(11) NOT NULL ,
  `SNAPSHOT_FN` VARCHAR(200) NOT NULL COMMENT 'snapshot of the CH in solarmonitor',
  `SNAPSHOT_PATH` VARCHAR(200) NOT NULL COMMENT 'full URL of the snapshot',
/*  `PM_CH_NUMBER` INT(11) NULL DEFAULT NULL ,*/
  PRIMARY KEY (`ID_CORONALHOLES`) ,
  INDEX `frc_info_fk_constraint_charm` (`FRC_INFO_ID` ASC) ,
  INDEX `observations_eit_fk_constraint` (`OBSERVATION_ID_EIT` ASC) ,
  INDEX `observations_mdi_fk_constraint` (`OBSERVATION_ID_MDI` ASC) ,
  INDEX `chgroups_fk_constraint` (`CHGROUPS_ID` ASC) , 
  CONSTRAINT `frc_info_fk_constraint_charm`
    FOREIGN KEY (`FRC_INFO_ID` )
    REFERENCES `hfc1test`.`FRC_Info` (`ID_FRC_INFO` ),
  CONSTRAINT `observations_eit_fk_constraint`
    FOREIGN KEY (`OBSERVATION_ID_EIT` )
    REFERENCES `hfc1test`.`OBSERVATIONS` (`ID_OBSERVATIONS` ),
  CONSTRAINT `observations_mdi_fk_constraint`
    FOREIGN KEY (`OBSERVATION_ID_MDI` )
    REFERENCES `hfc1test`.`OBSERVATIONS` (`ID_OBSERVATIONS` ),
  CONSTRAINT `chgroups_fk_constraint`
    FOREIGN KEY (`CHGROUPS_ID` )
    REFERENCES `hfc1test`.`CHGROUPS` (`ID_CHGROUPS` )) 
ENGINE = InnoDB
AUTO_INCREMENT = 0
DEFAULT CHARACTER SET = utf8
ROW_FORMAT = DYNAMIC;





SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;



