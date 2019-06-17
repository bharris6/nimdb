import asyncnet, asyncdispatch

import tables
import strutils, sequtils

var 
  clients {.threadvar.}: seq[AsyncSocket]
  kvStore = initTable[string, string]()


proc killClient(client: AsyncSocket) =
  var cIndex = clients.find(client)
  if cIndex >= 0:
    clients.del(cIndex)

proc sendClientResponse(client: AsyncSocket, data: string) {.async.} =
  echo "Operating on string: " & data
  var response: string
  var splitData: seq[string] = data.split()
  echo "Split Data: ", splitData
  case splitData[0].join().toUpper():
  of "GET":
    if kvStore.hasKey(splitData[1].join()):
      response = kvStore[splitData[1]]
    else:
      response = "KO"
  of "SET":
    if splitData.len == 3:
      kvStore[splitData[1].join()] = splitData[2].join()
      response = "OK"
    else:
      response = "KO"
  of "DELETE":
    kvStore.del(splitData[1])
    response = "OK"
  of "FLUSH":
    kvStore.clear()
    response = "OK"
  of "MGET":
    for i in 1..<splitData.len:
      try:
        response = response & " " & kvStore[splitData[i].join()]
      except:
        response = response & " KO"
      response = response.strip()
  of "MSET":
    for i in countup(1, splitData.len-2, 2):
      kvStore[splitData[i].join()] = splitData[i+1].join()
    response = "OK" 
  else:
    # raise newException(OSError, "Unrecognized Command: " & splitData[0].join())
    response = "KO"
  await client.send(response & "\c\L")

proc handleClientRequest(client: AsyncSocket, cdata: string) {.async.} =
  echo "Handling Client Request: " & cdata
  var line: string
  case $(cdata)
  of "+":
    let line = await client.recvLine()
    await sendClientResponse(client, line)
  #of "-":
  #  response = "Handling Error."
  #of ":":
  #  response = "Handling int."
  #of "$":
  #  response = "Handling String."
  #of "*":
  #  response = "Handling Array."
  #of "%":
  #  response = "Handling dict."
  else:
    line = "Unknown Request Type."
    await sendClientResponse(client, line)

proc processClient(client: AsyncSocket) {.async.} =
  while true:
    let cdata = await client.recv(1)
    if cdata.len == 0:
        killClient(client)
    else:
      await handleClientRequest(client, cdata)

proc serve() {.async.} = 
  clients = @[]
  var server = newAsyncSocket()

  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr( Port(12345) )
  server.listen()

  while true:
    let client = await server.accept()
    clients.add client

    asyncCheck processClient(client)


asyncCheck serve()
runForever()
