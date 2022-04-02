*/1 0-23 * * *  /home/wck/chd3backend/partition.sh >/dev/null 2>&1
*/1 0-23 * * *  /home/wck/chd3backend/partition15.sh >/dev/null 2>&1
*/1 0-23 * * *  /home/wck/chd3backend/partition30.sh >/dev/null 2>&1
*/1 0-23 * * *  /home/wck/chd3backend/partition45.sh >/dev/null 2>&1
*/1 * * * * /home/wck/bcdbackend/communicationDispatcher.sh >/dev/null 2>&1
*/1 0-23 * * *  /home/wck/chd3backend/images.sh >/dev/null 2>&1
*/1 0-23 * * *  /home/wck/chd3backend/reports.sh >/dev/null 2>&1
15 23 * * * /home/wck/chd3backend/paymentTXReport.sh >/dev/null 2>&1

### DC NEW Now call database script directly to weed
##*/15 * * * *  /home/wck/chd3backend/weed.sh wck >/dev/null 2>&1

### weed sessions
*/5 * * * * /home/wck/chd3backend/weedsess.sh wck sessions >/dev/null 2>&1

### Weed the Image system
*/30  * * * *  /home/wck/chd3backend/weedDocs.sh >/dev/null 2>&1
59 0 * * *  /home/wck/chd3backend/WCKdownloadStats.sh >/dev/null 2>&1
*/25 6-18 * * 1-6 /home/wck/chd3backend/monitorLockChecker.sh >/dev/null 2>&1
30 6 * * 1 /home/wck/chd3backend/getSpendingCusts.sh >/dev/null 2>&1
59 23 * * * /home/wck/chd3backend/lastDayOfMonth.sh && /home/wck/chd3backend/getWCKmonStats.sh >/dev/null 2>&1
0 6 * * 0 /home/wck/chd3backend/getCusts.sh >/dev/null 2>&1
