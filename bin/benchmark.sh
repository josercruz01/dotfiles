#!/bin/zsh
# Benchmark runner

# defaults
repeats=20

run_tests() {
    # --------------------------------------------------------------------------
    # Benchmark loop
    # --------------------------------------------------------------------------
    echo 'Benchmarking ' $command_to_run '...';
    # Indicate the command we just run in the csv file
    echo '======' $command_to_run '======' >> $output_file;

    # Run the given command [repeats] times
    for (( i = 1; i <= $repeats ; i++ ))
    do
        # percentage completion
        p=$(( $i * 100 / $repeats))
        # indicator of progress
        l=$(seq -s "+" $i | sed 's/[0-9]//g')

        gtime -f "%E,%U,%S" -o ${output_file} -a npm run test:ci

        echo -ne ${l}' ('${p}'%) \r'
    done;

    echo -ne '\n'

    # Convenience seperator for file
    echo '--------------------------' >> $output_file
}

usage() {
    echo "Usage: benchmark.sh -c 'echo 1' -o 'results.csv'"
    echo ""
    echo "Options:"
    echo "  -o=<name>:    output file name (required)"
    echo "  -c=<command>: command to run (required)"
    echo "  -n=<number>:  repeat number (default: 20)"
    exit 1
}

# Option parsing
while getopts n:c:o:h OPT
do
    case "$OPT" in
        n)
            repeats=$OPTARG
            ;;
        o)
            output_file=$OPTARG
            ;;
        c)
            command_to_run=$OPTARG
            ;;
        h)
            usage
            ;;
    esac
done

if [ -z "$output_file" ]
then
  echo "Error: missing required param [-o]"
  echo ""
  usage
  exit
fi

if [ -z "$command_to_run" ]
then
  echo "Error: missing required param [-c]"
  echo ""
  usage
  exit
fi
run_tests

shift `expr $OPTIND - 1`
