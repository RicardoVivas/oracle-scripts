-- Recovering the OCR using manually or auto generated backups

crsctl stop crs
crsctl start crs -excl
crsctl stop resource ora.crsd -init  (-- can these two steps merged as crsctl start crs -excl -nocrs ?)
ocrconfig -restore file_name
ocrcheck
crsctl stop crs -f
crsctl start crs
cluvfy comp ocr -n all [-verbose]


-- Recovering the OCR using manually generated exports
crsctl stop crs
crsctl start crs -excl -nocrs 
ocrconfig -import file_name
ocrcheck
crsctl stop crs -f
crsctl start crs
cluvfy comp ocr -n all [-verbose]




-- http://gjilevski.com/2010/12/20/backup-and-restore-of-ocr-in-grid-infrastructure-11g-r2-11-2-2/

