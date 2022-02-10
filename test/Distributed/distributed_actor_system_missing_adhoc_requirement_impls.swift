// RUN: %target-swift-frontend -typecheck -verify -enable-experimental-distributed -disable-availability-checking -I %t 2>&1 %s

// UNSUPPORTED: back_deploy_concurrency
// REQUIRES: concurrency
// REQUIRES: distributed

import _Distributed

public struct ActorAddress: Sendable, Hashable, Codable {
  let address: String
  init(parse address: String) {
    self.address = address
  }
}

struct MissingRemoteCall: DistributedActorSystem {
  // expected-error@-1{{struct 'MissingRemoteCall' is missing witness for protocol requirement 'remoteCall'}}
  // expected-note@-2{{protocol 'MissingRemoteCall' requires function 'remoteCall' with signature:}}

  // expected-error@-4{{struct 'MissingRemoteCall' is missing witness for protocol requirement 'remoteCallVoid'}}
  // expected-note@-5{{protocol 'MissingRemoteCall' requires function 'remoteCallVoid' with signature:}}

  typealias ActorID = ActorAddress
  typealias InvocationDecoder = FakeInvocationDecoder
  typealias InvocationEncoder = FakeInvocationEncoder
  typealias SerializationRequirement = Codable

  func resolve<Act>(id: ActorID, as actorType: Act.Type)
    throws -> Act? where Act: DistributedActor {
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
    where Act: DistributedActor {
    ActorAddress(parse: "fake://123")
  }

  func actorReady<Act>(_ actor: Act)
    where Act: DistributedActor,
    Act.ID == ActorID {
  }

  func resignID(_ id: ActorID) {
  }

  func makeInvocationEncoder() -> InvocationEncoder {
  }
}

struct Error_wrongReturn: DistributedActorSystem {
  // expected-error@-1{{struct 'Error_wrongReturn' is missing witness for protocol requirement 'remoteCall'}}
  // expected-note@-2{{protocol 'Error_wrongReturn' requires function 'remoteCall' with signature:}}

  // expected-error@-4{{struct 'Error_wrongReturn' is missing witness for protocol requirement 'remoteCallVoid'}}
  // expected-note@-5{{protocol 'Error_wrongReturn' requires function 'remoteCallVoid' with signature:}}

  typealias ActorID = ActorAddress
  typealias InvocationDecoder = FakeInvocationDecoder
  typealias InvocationEncoder = FakeInvocationEncoder
  typealias SerializationRequirement = Codable

  func resolve<Act>(id: ActorID, as actorType: Act.Type)
    throws -> Act? where Act: DistributedActor {
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
    where Act: DistributedActor {
    ActorAddress(parse: "fake://123")
  }

  func actorReady<Act>(_ actor: Act)
    where Act: DistributedActor,
    Act.ID == ActorID {
  }

  func resignID(_ id: ActorID) {
  }

  func makeInvocationEncoder() -> InvocationEncoder {
  }

  public func remoteCall<Act, Err, Res>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation invocationEncoder: inout InvocationEncoder,
    throwing: Err.Type,
    returning: Res.Type
  ) async throws -> String // ERROR: wrong return type
    where Act: DistributedActor,
    Act.ID == ActorID,
    Err: Error,
    Res: SerializationRequirement {
    throw ExecuteDistributedTargetError(message: "Not implemented.")
  }

  public func remoteCall<Act, Err, Res>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation invocationEncoder: inout InvocationEncoder,
    throwing: Err.Type,
    returning: Res.Type
  ) async throws // ERROR: wrong return type (void)
    where Act: DistributedActor,
    Act.ID == ActorID,
    Err: Error,
    Res: SerializationRequirement {
    throw ExecuteDistributedTargetError(message: "Not implemented.")
  }

  public func remoteCallVoid<Act, Err>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation invocationEncoder: inout InvocationEncoder,
    throwing: Err.Type
  ) throws -> String // ERROR: should not return anything
    where Act: DistributedActor,
    Act.ID == ActorID,
    Err: Error {
    throw ExecuteDistributedTargetError(message: "Not implemented.")
  }
}

struct BadRemoteCall_param: DistributedActorSystem {
  // expected-error@-1{{struct 'BadRemoteCall_param' is missing witness for protocol requirement 'remoteCall'}}
  // expected-note@-2{{protocol 'BadRemoteCall_param' requires function 'remoteCall' with signature:}}

  // expected-error@-4{{struct 'BadRemoteCall_param' is missing witness for protocol requirement 'remoteCallVoid'}}
  // expected-note@-5{{protocol 'BadRemoteCall_param' requires function 'remoteCallVoid' with signature:}}

  typealias ActorID = ActorAddress
  typealias InvocationDecoder = FakeInvocationDecoder
  typealias InvocationEncoder = FakeInvocationEncoder
  typealias SerializationRequirement = Codable

  func resolve<Act>(id: ActorID, as actorType: Act.Type)
    throws -> Act? where Act: DistributedActor {
    return nil
  }

  func assignID<Act>(_ actorType: Act.Type) -> ActorID
    where Act: DistributedActor {
    ActorAddress(parse: "fake://123")
  }

  func actorReady<Act>(_ actor: Act)
    where Act: DistributedActor,
    Act.ID == ActorID {}
  func resignID(_ id: ActorID) {}
  func makeInvocationEncoder() -> InvocationEncoder {
  }

  public func remoteCall<Act, Err, Res>(
    on actor: Act,
    target: RemoteCallTarget,
    // invocation invocationEncoder: inout InvocationEncoder, // ERROR: missing parameter
    throwing: Err.Type,
    returning: Res.Type
  ) async throws -> Res
    where Act: DistributedActor,
    Act.ID == ActorID,
    Err: Error,
    Res: SerializationRequirement {
    throw ExecuteDistributedTargetError(message: "Not implemented.")
  }

  public func remoteCallVoid<Act, Err>(
    on actor: Act,
    target: RemoteCallTarget,
    // invocation invocationEncoder: inout InvocationEncoder, // ERROR: missing parameter
    throwing: Err.Type
  ) async throws
    where Act: DistributedActor,
    Act.ID == ActorID,
    Err: Error {
    throw ExecuteDistributedTargetError(message: "Not implemented.")
  }
}

public struct BadRemoteCall_notPublic: DistributedActorSystem {
  public typealias ActorID = ActorAddress
  public typealias InvocationDecoder = PublicFakeInvocationDecoder
  public typealias InvocationEncoder = PublicFakeInvocationEncoder
  public typealias SerializationRequirement = Codable

  public func resolve<Act>(id: ActorID, as actorType: Act.Type)
    throws -> Act? where Act: DistributedActor {
    return nil
  }

  public func assignID<Act>(_ actorType: Act.Type) -> ActorID
    where Act: DistributedActor {
    ActorAddress(parse: "fake://123")
  }

  public func actorReady<Act>(_ actor: Act)
    where Act: DistributedActor,
    Act.ID == ActorID {}
  public func resignID(_ id: ActorID) {}
  public func makeInvocationEncoder() -> InvocationEncoder {
  }

  // expected-error@+1{{method 'remoteCall(on:target:invocation:throwing:returning:)' must be as accessible as its enclosing type because it matches a requirement in protocol 'DistributedActorSystem'}}
  func remoteCall<Act, Err, Res>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation invocationEncoder: inout InvocationEncoder,
    throwing: Err.Type,
    returning: Res.Type
  ) async throws -> Res
    where Act: DistributedActor,
          Act.ID == ActorID,
          Err: Error,
          Res: SerializationRequirement {
    throw ExecuteDistributedTargetError(message: "Not implemented.")
  }

  // expected-error@+1{{method 'remoteCallVoid(on:target:invocation:throwing:)' must be as accessible as its enclosing type because it matches a requirement in protocol 'DistributedActorSystem'}}
  func remoteCallVoid<Act, Err>(
    on actor: Act,
    target: RemoteCallTarget,
    invocation invocationEncoder: inout InvocationEncoder,
    throwing: Err.Type
  ) async throws 
    where Act: DistributedActor,
    Act.ID == ActorID,
    Err: Error {
    throw ExecuteDistributedTargetError(message: "Not implemented.")
  }
}


// ==== ------------------------------------------------------------------------

struct FakeInvocationEncoder: DistributedTargetInvocationEncoder {
  typealias SerializationRequirement = Codable

  mutating func recordGenericSubstitution<T>(_ type: T.Type) throws {}
  mutating func recordArgument<Argument: SerializationRequirement>(_ argument: Argument) throws {}
  mutating func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws {}
  mutating func recordErrorType<E: Error>(_ type: E.Type) throws {}
  mutating func doneRecording() throws {}
}

public struct PublicFakeInvocationEncoder: DistributedTargetInvocationEncoder {
  public typealias SerializationRequirement = Codable

  public mutating func recordGenericSubstitution<T>(_ type: T.Type) throws {}
  public mutating func recordArgument<Argument: SerializationRequirement>(_ argument: Argument) throws {}
  public mutating func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws {}
  public mutating func recordErrorType<E: Error>(_ type: E.Type) throws {}
  public mutating func doneRecording() throws {}
}

class FakeInvocationDecoder : DistributedTargetInvocationDecoder {
  typealias SerializationRequirement = Codable

  func decodeGenericSubstitutions() throws -> [Any.Type] { [] }
  func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument { fatalError() }
  func decodeReturnType() throws -> Any.Type? { nil }
  func decodeErrorType() throws -> Any.Type? { nil }
}

public final class PublicFakeInvocationDecoder : DistributedTargetInvocationDecoder {
  public typealias SerializationRequirement = Codable

  public func decodeGenericSubstitutions() throws -> [Any.Type] { [] }
  public func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument { fatalError() }
  public func decodeReturnType() throws -> Any.Type? { nil }
  public func decodeErrorType() throws -> Any.Type? { nil }
}

struct FakeResultHandler: DistributedTargetInvocationResultHandler {
  typealias SerializationRequirement = Codable

  func onReturn<Res>(value: Res) async throws {
    print("RETURN: \(value)")
  }
  func onThrow<Err: Error>(error: Err) async throws {
    print("ERROR: \(error)")
  }
}

public struct PublicFakeResultHandler: DistributedTargetInvocationResultHandler {
  public typealias SerializationRequirement = Codable

  public func onReturn<Res>(value: Res) async throws {
    print("RETURN: \(value)")
  }
  public func onThrow<Err: Error>(error: Err) async throws {
    print("ERROR: \(error)")
  }
}

