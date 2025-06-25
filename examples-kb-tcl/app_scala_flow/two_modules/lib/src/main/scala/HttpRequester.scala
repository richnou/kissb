import sttp.client4.{Response, UriContext, quickRequest}
import  sttp.client4.quick.*

object HttpRequester {


  def sendRequest(): Response[String] = {
     quickRequest
      .get(uri"https://httpbin.org/get")
      .send()
  }
}
