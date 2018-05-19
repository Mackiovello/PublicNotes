import os 
import subprocess
from configuration import config
import coverage
from datetime import datetime, timedelta, timezone

os.chdir(config['nova_path'])

subprocess.call(["git", "checkout", "-f", "develop"])
subprocess.call(["git", "pull"])

last_commit_date = subprocess.check_output(["git", "log", "-1", "--format=%cd"])

# Git date format: Fri May 18 09:08:54 2018 +0200
last_commit_date = datetime.strptime(str(last_commit_date, 'utf-8').strip(), "%c %z")

current_date = datetime.now(timezone.utc)

seven_days_ago = current_date - timedelta(days=7)

if last_commit_date > seven_days_ago:
    coverage_file_path = os.path.join(config['nova_path'], 'coverage.xml')
    coverage.generate(coverage_file_path)
    coverage.push_to_coveralls(config['nova_path'], 'coverage.xml')