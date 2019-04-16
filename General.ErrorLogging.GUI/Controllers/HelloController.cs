using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace General.ErrorLogging.GUI.Controllers
{

    public class HelloController : ApiController
    {
        // GET api/hello
        public string Get()
        {
            return "welcome!";
        }

        // POST api/hello
        public void Post([FromBody]string value)
        {
            throw new NotImplementedException();
        }

        // PUT api/hello/value
        public void Put(int id, [FromBody]string value)
        {
            throw new NotImplementedException();
        }

        // DELETE api/hello/value
        public void Delete(int id)
        {
            throw new NotImplementedException();
        }
    }
}