package kissb

import jakarta.ws.rs.Path
import jakarta.ws.rs.GET

@Path("/hello")
class TestEndpoint {
    

    @GET
    def v() = {
        "World!"
    }
}
