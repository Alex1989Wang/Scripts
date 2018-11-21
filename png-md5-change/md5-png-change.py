from os import remove
import hashlib, argparse, glob


def main(dirs):
    """the main function to execute"""

    for cur_dir in dirs:
        only_images = glob.glob(cur_dir + '/**/*.png', recursive=True)
        print(only_images)

        for png in only_images:

            file = open(png, 'rb').read()
            print("original file: " + png + " md5: " + hashlib.md5(file).hexdigest())
            new_file_path = png + "_temp"
            with open(new_file_path, 'wb') as new_file:
                new_file.write(file + '\0'.encode('ascii'))
            print("new file: " + new_file_path + " md5: " + hashlib.md5(open(new_file_path, 'rb').read()).hexdigest())

            remove(png)

            new_file = open(new_file_path, 'rb').read()

            original_file_path = png
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

