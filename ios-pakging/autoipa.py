import os
import time

'''
script configs
'''
project_name = "Your_Project_Name"
scheme_name = "Your_Scheme_Name" #use 'xcodebuild -list' to find out
project_path = "Project_Absolute_Path"
archive_path = "Archive_Absolute_Path"
ipa_path = "IPAs_subPath"
export_options_plist = "Export_Options_Plist_Path"

'''
Example

project_name = "MyProduct"
scheme_name = "MyProduct"
project_path = "/Users/jiang/Desktop/Projects/myproduct"
archive_path = "/Users/jiang/Desktop/Projects/myproduct/build"
ipa_path = "ipas"
export_options_plist = "/Users/jiang/Desktop/Projects/myproduct/build/ad-hoc.plist"
'''

'''
ad-hoc.plist 

see xcodebuild -help to find out more configs for exportOptionsPlist file

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>method</key>
        <string>ad-hoc</string>

        <key>teamID</key>
        <string>Your_Ten_Character_Team_Id</string>

        <key>provisioningProfiles</key>
        <dict>
        <key>Your_Product_Bundle_Id</key>
        <string>Ad_Hoc_Profile_Name</string>
        </dict>

        <key>signingCertificate</key>
        <string>iOS Distribution</string>

</dict>
</plist>
~

'''


def check_os():
    """This script should only be run on posix system"""
    print("Info- os type: %s" % os.name)
    return os.name == 'posix'


def has_project_file():
    print("Info- contents of project directory: %s" % os.listdir(project_path))
    hasProjectFile = False
    for content in os.listdir(project_path):
        if content.endswith('.xcodeproj'):
            hasProjectFile = True
            break
    return hasProjectFile


def has_workspace_file():
    print("Info- contents of project directory: %s" % os.listdir(project_path))
    hasWorkspaceFile = False
    for content in os.listdir(project_path):
        if content.endswith('.xcworkspace'):
            hasWorkspaceFile = True
            break
    return hasWorkspaceFile


def clean_dirs():
    """clean project and archive directories."""
    os.system('cd %s; xcodebuild clean' % project_path)
    ipas_path = os.path.join(archive_path, ipa_path)
    if os.path.isdir(ipas_path):
        os.rmdir(ipas_path)

    #recreate a new folder
    os.makedirs(ipas_path, mode=0o777, exist_ok=False)
    assert os.path.isdir(ipas_path)


def archive_product():
    """use xcodebuild to archive product."""
    current_time = time.strftime('%Y-%m-%d-%H-%M-%S', time.localtime(time.time()))
    archive_name = project_name + current_time + '.xcarchive'
    full_archive_path = os.path.join(archive_path, archive_name)
    # cd to project directory
    os.system(
        'cd {0}; '
        'pwd; '
        'xcodebuild -workspace {1}.xcworkspace -scheme {2} -sdk iphoneos '
        '-configuration Release archive -archivePath {3}'
            .format(project_path, project_name, scheme_name, full_archive_path)
    )

    #export archive
    export_path = os.path.join(archive_path, ipa_path)
    if os.path.isfile(export_options_plist):
        os.system(
            'xcodebuild -exportArchive -archivePath {0} -exportOptionsPlist {1} -exportPath {2}'
            .format(full_archive_path, export_options_plist, export_path)
        )
    else:
        print("Error- no archive options plist file found.")
        exit(1)


def main():
    """The main function"""
    # check the os type
    if not check_os():
        print("Error- os type not valid.")
        exit(1)

    if not has_project_file():
        print("Error- project file not found - check project directory config: %s" % project_path)
        exit(1)

    # clean project dirs
    clean_dirs()

    if not has_workspace_file():
        print("Info- doesn't have workspace file -- use project file")
    else:
        archive_product()



if __name__ == '__main__':
    """run the main method if this script is executed."""

    main()


