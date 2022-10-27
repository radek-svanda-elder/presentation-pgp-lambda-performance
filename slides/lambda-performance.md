---
marp: true
theme: default
paginate: true
---

# AWS Lambda function performance

![bg fit right 75%](../img/lambda-light.svg)

Radek Švanda <radek.svanda@aurora.io>

<!--
-->

----

## Topics

- Lambda function lifecycle
- General recommendations
- Active tracing
- Application overview
- Kotlin
- Java
- GraalVM

----

![bg](../img/lifecycle.png)

----

## Easy wins

- Remove unnecessary dependencies
  Smaller package = faster upload & faster cold start
  ```
  mvn dependency:tree
  ```

* JDK JIT compiler C1 only - almost 100% speed gain instantly
  ```yaml
  Environment
    Variables:
      JAVA_TOOL_OPTIONS: "-XX:+TieredCompilation -XX:TieredStopAtLevel=1"
  ```

* Initialize as much as possible during start-up (**but only what you really need**)

----

- Exclude AWS SDK http clients - you run in a single thread you do not need NIO

  ```xml
  <dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>url-connection-client</artifactId>
  </dependency>
  <groupId>software.amazon.awssdk</groupId>
    <artifactId>s3</artifactId>
    <exclusions>
      <exclusion>
        <groupId>software.amazon.awssdk</groupId>
        <artifactId>apache-client</artifactId>
      </exclusion>
      <exclusion>
        <groupId>software.amazon.awssdk</groupId>
        <artifactId>netty-nio-client</artifactId>
      </exclusion>
    </exclusions>
  </dependency>
  ```

----

- Fully configure AWS SDK clients
  ```java
  S3Client.builder()
    .region(Region.of(System.getenv("AWS_REGION")))
    .httpClient(UrlConnectionHttpClient.builder().build()).build()
  ```

* Ditch sophisticated logging
  ```java
  override fun handleRequest(input: SQSEvent, context: Context) {
    context.logger.log("hello there")
  ```
  Falls back to
  ```java
  public void log(String message) { System.out.print(message) }
  ```

----

## Tracing the function with XRay

- Opentelemetry (preffered, flexible) vs. X-Ray SDK (tight integration)

* Turn on the tracing
  ```yaml
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      Tracing: Active
  ```

* Send tracing data (use BOM `aws-xray-recorder-sdk-bom` for versioning)
  ```xml
  <dependency>
    <groupId>com.amazonaws</groupId>
    <artifactId>aws-xray-recorder-sdk-aws-sdk-v2</artifactId>
  </dependency>
  ```

----

## Tracing Subsegments

- Anywhere in your code
  ```kotlin
  override fun handleRequest(input: SQSEvent, context: Context) {
    AWSXRay.beginSubsegment("Request handler")
    try { ... }
    finally { AWSXRay.endSubsegment() }
  }
  ```

- AWS SDKs
  ```kotlin
  S3Client.builder()
    .overrideConfiguration(ClientOverrideConfiguration.builder()
        .addExecutionInterceptor(TracingInterceptor()).build()
    )
  ```

----

![](../img/timeline-preview.png)

----

## Application overview

![bg fit right](../img/pipeline-deployment.png)

### Decryption function

- Written in Kotlin
- Steps:
  - Downloads file from S3
  - Decrypts contents with PGP
  - Uploads decrypted file back

----

## 1st iteration: Micronaut framework

![bg right:25% 100%](../img/micronaut.png)

Pros:

- Out of the box Spring framework replacement
- Test tooling with mocking and spock integration
- Integration with ParamStore / SecretsManager

Problems:

- Package too large
- Every. Single. One. Configuration property requested from ParamStore during startup

----

## 2nd iteration: Plain Kotlin

- Removed Micronaut
- Makefile packaged
- Most parameters configured during deployment

Pros:

- Smaller package, faster deploy

Cons:

- Manual configuration handling
- Params security (visible variables in Lambda console)

----

## 3rd iteration: Back to Java 11

----

## 4th iteration: GraalVM native-image

- an ELF linux binary build from Java bytecode. See https://www.graalvm.org/22.3/reference-manual/native-image/

Pros:

- A fast binary
- Small package to upload
  80 MB binary package -> 20 MB zipped upload

Cons:

- Everything has to be baked in during compile time
  No reflexion during runtime (DI frameworks, logging, ...)
- Sloooow build times

----

## AWS Lambda custom runtimes

![bg contain right:75%](../charts/custom-runtime-lifecycle.svg)

----

# Thanks for your attention

![bg fit right 50%](../img/mug.jpg)

Radek Švanda
[radek.svanda@aurora.io](radek.svanda@aurora.io)
