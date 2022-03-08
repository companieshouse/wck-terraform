#STAGING## Partition orders into product groups every minute
#STAGING#*/1 7-18 * * *  /home/wck/chd3backend/partition.sh

#STAGING## Generate reports mon-sat 7am->midnight every minute
#STAGING#*/1 7-18 * * *  /home/wck/chd3backend/reports.sh

#STAGING## Generate images mon-sat 7am->midnight
#STAGING#*/1 7-18 * * *  /home/wck/chd3backend/images.sh

#STAGING## Generate scud mon-sat 7am->midnight
#STAGING#*/1 7-18 * * *  /home/wck/chd3backend/scud.sh

#STAGING## Generate (charge) monitor orders mon-sat 7am->midnight
#STAGING#*/1 7-18 * * *  /home/wck/chd3backend/monitor.sh

#STAGING###barclays payments reports
#STAGING##*/1 * * * * /home/wck/chd3backend/paymentTXProcessOrder.sh
#STAGING#*/1 * * * * /home/wck/chd3backend/paymentTXCommunicate.sh
#STAGING#55 12 * * * /home/wck/chd3backend/paymentTXReport.sh

#STAGING## Do monitor Matching process mon-sat every 10 mins
#STAGING## (This should only pick up matches once - but for testing purposes......)
#STAGING##
#STAGING##*/10 7-18 * * *  /home/wck/chd3backend/monitorMatch.sh
#STAGING## Weeding (session and everything else)
#STAGING##
#STAGING##*/10 7-18 * * *  /home/wck/chd3backend/weedall.sh
#STAGING### -- Webcheck does not require the following --
#STAGING## Generate packages mon-sat 7am->midnight
#STAGING##
#STAGING###*/1 7-18 * * *  /home/wck/chd3backend/packages.sh
#STAGING## Generate scud mon-sat 7am->midnight
#STAGING##
#STAGING###*/1 7-18 * * *  /home/wck/chd3backend/scud.sh
#STAGING## Generate fiche mon-sat 7am->midnight
#STAGING##
#STAGING###*/1 7-18 * * *  /home/wck/chd3backend/fiche.sh
#STAGING## Dispatch Faxes mon-sat 7am->midnight
#STAGING##
#STAGING####*/1 7-18 * * *  /home/wck/chd3backend/fax.sh
#STAGING## Scan for and record Fax delivery status to CH report dir and to Database
#STAGING##
#STAGING###*/5 7-18 * * *  /home/wck/chd3backend/faxStatus.sh
#STAGING## -- Webcheck does not require the Above --
#STAGING## new for password reset functionality
#STAGING#*/1 * * * * /home/wck/bcdbackend/communicationDispatcher.sh
