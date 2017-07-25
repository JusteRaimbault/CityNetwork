
TASK=$1


if [ "$TASK" == "--keywords" ]
then
  echo "Running keywords extraction..."
  SOURCE=$2
  OUT=$3
  python Semantic/main.py --keywords-extraction $SOURCE $OUT
fi
