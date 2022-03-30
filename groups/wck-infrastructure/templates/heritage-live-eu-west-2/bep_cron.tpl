#LIVE##*/1 0-23 * * *  /home/wck/chd3backend/partition.sh >/dev/null 2>&1
#LIVE##*/1 0-23 * * *  /home/wck/chd3backend/partition15.sh >/dev/null 2>&1
#LIVE##*/1 0-23 * * *  /home/wck/chd3backend/partition30.sh >/dev/null 2>&1
#LIVE##*/1 0-23 * * *  /home/wck/chd3backend/partition45.sh >/dev/null 2>&1
#LIVE##*/1 * * * * /home/wck/bcdbackend/communicationDispatcher.sh >/dev/null 2>&1
#LIVE##*/1 0-23 * * *  /home/wck/chd3backend/images.sh >/dev/null 2>&1
#LIVE##*/1 0-23 * * *  /home/wck/chd3backend/reports.sh >/dev/null 2>&1
#LIVE##15 23 * * * /home/wck/chd3backend/paymentTXReport.sh >/dev/null 2>&1

#LIVE### fix potential missing mondoctypes BEFORE monitor matches goes off
#LIVE###28 11 * * * /home/wck/chd3backend/monitorFixMonDocTypes.sh >/dev/null 2>&1

#LIVE### DC NEW Now call database script directly to weed
#LIVE##*/15 * * * *  /home/wck/chd3backend/weed.sh wck >/dev/null 2>&1

#LIVE### weed sessions
#LIVE##*/5 * * * * /home/wck/chd3backend/weedsess.sh wck sessions >/dev/null 2>&1

#LIVE### Weed the Image system
#LIVE##*/30  * * * *  /home/wck/chd3backend/weedDocs.sh >/dev/null 2>&1
#LIVE##59 0 * * *  /home/wck/WCKdownloadStats.sh >/dev/null 2>&1
#LIVE##*/25 6-18 * * 1-6 /home/wck/chd3backend/monitorLockChecker.sh >/dev/null 2>&1
#LIVE##30 6 * * 1 /home/wck/chd3backend/getSpendingCusts.sh >/dev/null 2>&1
#LIVE##59 23 * * * /home/wck/chd3backend/lastDayOfMonth.sh && /home/wck/chd3backend/getWCKmonStats.sh >/dev/null 2>&1

#LIVE### turned off 27/04/2020
#LIVE###0 6 * * 1 /home/wck/chd3backend/getWeeklyMonitorStats.sh >/dev/null 2>&1
#LIVE##0 6 * * 0 /home/wck/chd3backend/getCusts.sh >/dev/null 2>&1
