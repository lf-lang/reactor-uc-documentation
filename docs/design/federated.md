
# Federated Execution


## Startup Coordination

``` mermaid
sequenceDiagram
  fed0->>fed1: StartupHandshakeRequest
  fed1->>fed0: StartupHandshakeRespone
  loop start tag gossip
    fed1->>fed0: StartTimeProposal
    fed0->>fed1: StartTimeProposal
  end
```

## Transient Joining


``` mermaid
sequenceDiagram
  transient_federate->>running_federate: StartupHandshakeRequest
  running_federate->>transient_federate: StartupHandshakeRespone
  transient_federate->>running_federate: StartTimeRequest
  running_federate->>transient_federate: StartTimeResponse
  transient_federate->>running_federate: JoiningTimeAnnouncement
```

## Messages

```protobuf
message TaggedMessage {
  required Tag tag = 1;
  required int32 conn_id = 2;
  required bytes payload = 3 [(nanopb).max_size = 832];
}
```


## Clock-Synchronization


