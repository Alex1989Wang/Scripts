from os import remove, path
import hashlib, argparse, glob


def main(dirs, prefix, proj_file):
    """the main function to execute"""

    """
    the project file must exist
    """
    assert path.isfile(proj_file)

    for cur_dir in dirs:
        """
        filter only the source files
        """
        # only_files = glob.glob('{cur_dir}/**/{pre}*.(h|m|xib)'.format(cur_dir=cur_dir, pre=prefix), recursive=True)
        only_files = glob.glob(cur_dir + '/**/*.h'.format(cur_dir=cur_dir), recursive=True)
        print(only_files)

        """
        for file in only_files:
            if not path.isfile(file):
                continue

            file_binary = open(file, 'rb').read()
            print("original file: " + file + " md5: " + hashlib.md5(file_binary).hexdigest())
            new_file_path = file + "_temp"
            with open(new_file_path, 'wb') as new_file:
                new_file.write(file_binary + '\0'.encode('ascii'))
            print("new file: " + new_file_path + " md5: " + hashlib.md5(open(new_file_path, 'rb').read()).hexdigest())

            remove(file)

            new_file = open(new_file_path, 'rb').read()

            original_file_path = file
            with open(original_file_path, 'wb') as original_file:
                original_file.write(new_file)
            remove(new_file_path)
        """


if __name__ == '__main__':
    """run the main method if this script is executed."""

    parser = argparse.ArgumentParser(description="Parse input parameters to rename files in XCode")
    parser.add_argument('file_prefix', metavar='pre', type=str, nargs=1, help='The file name prefix to match.')
    parser.add_argument('directories', metavar='DIR', type=str, nargs='+', help='The directory to search recursively.')
    parser.add_argument('project_file', metavar='proj', type=str, nargs=1, help='The XCode project file.')
    args = parser.parse_args()
    print(args.file_prefix[0], args.project_file[0], args.directories)

    main(args.directories, args.file_prefix[0], args.project_file[0])

