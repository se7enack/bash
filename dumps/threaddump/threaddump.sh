
set -e

DATE=$(date +%F-%H)
HOSTNAME=$(hostname -I | awk '{print $1}')
namespace=${1}
pod=${2}

echo "Namespace: ${namespace} Pod: ${pod}"

TMPFILE=/tmp/.${namespace}_${pod}${DATE}.tmp
FILE=/tmp/${namespace}_${pod}${DATE}.txt

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


echo;echo "Pod:" ${pod}
echo "Container:" ${container}
echo "Java Process ID: " ${jpid};echo

longHaul() {
  echo "Creating thread dump file..."
  kubectl exec -i ${pod} -n ${namespace} -- jstack -l ${jpid} > /tmp/${namespace}_${pod}${DATE}.txt
  echo;echo "Copying thread dump file to local tmp directory..."
  kubectl cp ${namespace}/${pod}:/tmp/${namespace}_${pod}${DATE}.txt -c ${container} /tmp/${namespace}_${pod}${DATE}.txt > /dev/null
  echo;echo "Now removing the original copy from the container..."
  kubectl exec -i ${pod} -n ${namespace} -- rm -rf /tmp/${namespace}_${pod}${DATE}.txt
  echo;echo "Completed: Thread dump file has been created on local machine: /tmp/${namespace}_${pod}${DATE}.txt"
  echo;echo "<br><a href="${namespace}_${pod}${DATE}.txt">${DATE} ${pod}</a><br>" >> /tmp/index.html
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\":alert: A thread dump was auto-generated for ${pod}.\n It can be downloaded here:\n http://${HOSTNAME}/${namespace}_${pod}${DATE}.txt\"}" ${selfhealbotslackurl}
  rm $TMPFILE
}
longHaul &