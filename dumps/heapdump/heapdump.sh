
set -e

namespace=${1}
pod=${2}
DATE=$(date +%F-%H)
HOSTNAME=$(hostname -I | awk '{print $1}')
TMPFILE=/tmp/.${pod}${DATE}_heap.tmp
FILE=/tmp/${pod}${DATE}_heap.tar.gz

if [ -f "$TMPFILE" ]; then
  echo "Process already running"
  exit
elif [ -f "$FILE" ]; then
  echo "A dump for this pod has already been created within the last hour"
  exit
fi

touch $TMPFILE

pod=$(kubectl get po -n ${namespace} | grep ${pod} | awk '{ print $1 }')
container=$(kubectl describe pod ${pod} -n ${namespace} | grep -a1 Containers | grep "  ${namespace}-" | tr -d :)
jpid=$(kubectl exec -i ${pod} -n ${namespace} -- ps -e | grep java  | awk '{ print $1 }')
echo "jpid: " ${jpid};echo "------";echo

longHaul(){
  echo "Creating heap dump file..."
  kubectl exec -it ${pod} -n ${namespace} -- jmap -dump:file=/tmp/${pod}${DATE}_heap.hprof ${jpid}
  echo;echo "Copying heap dump file to local tmp directory..."
  kubectl cp ${namespace}/${pod}:/tmp/${pod}${DATE}_heap.hprof  -c ${container} /tmp/${pod}${DATE}_heap.hprof > /dev/null
  tar -czvf /tmp/${pod}${DATE}_heap.tar.gz /tmp/${pod}${DATE}_heap.hprof 2> /dev/null
  echo "Created compressed version: /tmp/${pod}${DATE}_heap.tar.gz"
  echo "Now removing the original copy from the container and removing the untar'd copy locally"
  kubectl exec -it ${pod} -n ${namespace} -- rm -rf /tmp/${pod}${DATE}_heap.hprof
  rm -f /tmp/${pod}${DATE}_heap.hprof
  echo;echo "Completed: heap dump file has been created on local machine: /tmp/${pod}${DATE}_heap.tar.gz"
  echo;echo "<br><a href="${pod}${DATE}_heap.tar.gz">${DATE} ${pod}</a><br>" >> /tmp/index.html
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\":alert: A heap dump was auto-generated for ${pod}.\n It can be downloaded here:\n http://${HOSTNAME}/${pod}${DATE}_heap.tar.gz\"}" ${selfhealbotslackurl}
  rm $TMPFILE
}
longHaul &