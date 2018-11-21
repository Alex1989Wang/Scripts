from os import remove, path
import hashlib, argparse, glob


def main(dirs):
    """the main function to execute"""

    for cur_dir in dirs:
        text_files = glob.glob(cur_dir + '/**/*.[h|m]', recursive=True)
        print(text_files)

        for file in text_files:
            if not path.isfile(file):
                continue

            file_binary = open(file, 'rb').read()
            print("original file: " + file + " md5: " + hashlib.md5(file_binary).hexdigest())
            new_file_path = file + "_temp"
            with open(new_file_path, 'wb') as new_file:
                new_file.write(file_binary + '\n'.encode('ascii'))
            print("new file: " + new_file_path + " md5: " + hashlib.md5(open(new_file_path, 'rb').read()).hexdigest())

            remove(file)

            new_file = open(new_file_path, 'rb').read()

            original_file_path = file
            with open(original_file_path, 'wb') as original_file:
                original_file.write(new_file)
            remove(new_file_path)


if __name__ == '__main__':
    """run the main method if this script is executed."""

    parser = argparse.ArgumentParser(description="directory parser")
    parser.add_argument('directories', metavar='DIR', type=str, nargs='+', help='Input the directory to change images.')
    args = parser.parse_args()
    print(args.directories)

    main(args.directories)

