-- adb shell pm list packages | grep campus_picks | sed 's/package://' | xargs -I {} adb exec-out run-as {} cat /data/data/{}/databases/matches.db > matches.db
-- sqlite3 matches.db

SELECT COUNT(*) 
  FROM error_logs 
 WHERE timestamp >= datetime('now','-7 days');

SELECT endpoint, COUNT(*) AS count
  FROM error_logs
 WHERE timestamp >= datetime('now','-7 days')
 GROUP BY endpoint;