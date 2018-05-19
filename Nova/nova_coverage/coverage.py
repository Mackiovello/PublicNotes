import os
from configuration import config
import subprocess

def generate(coverage_file_path):
    file = open(coverage_file_path, 'w')
    file.close()

    os.chdir(config['nova_path'])

    # So we don't have to build and restore on every test run
    subprocess.call(["dotnet", "build"])

    os.chdir("test")

    test_directories = [x for x in next(os.walk('.'))[1] if x.endswith('.Tests')]

    open_cover_exe = os.path.join(config['global_nuget_cache_path'], 'opencover\\4.6.519\\tools\\OpenCover.Console.exe')

    for directory in test_directories:
        os.chdir(directory)

        # This throws an XmlException on the first run. It doesn't stop the process and
        # everything still works
        #
        # Starcounter.Nova.Database.Tests.Tests.AsyncLambdaKeepsTransaction(Int32 contextLimit)
        # Fails when called this way. I don't know why. It's worth investigating
        subprocess.call([
            open_cover_exe, 
            '-target:dotnet.exe', 
            '-register:user', 
            '-targetargs:test -f netcoreapp2.0 --no-restore --no-build',
            '-oldstyle',
            f'-output:{coverage_file_path}', 
            '-mergeoutput', 
            '-filter:"+[Starcounter.Nova*]* -[Starcounter.Nova.*.Tests]*"'])
        os.chdir('../')

def push_to_coveralls(path_to_coverage_directory, coverage_file_name, job_id = 0):
    repo_token = config['repo_token']
    os.chdir(path_to_coverage_directory)
    coveralls_exe = os.path.join(config['global_nuget_cache_path'], 'coveralls.net\\0.7.0\\tools\\csmacnz.Coveralls.exe')
    push_command = f'{coveralls_exe} --opencover -i ./{coverage_file_name} --repoToken {repo_token} --jobId {job_id}'
    subprocess.call(push_command)