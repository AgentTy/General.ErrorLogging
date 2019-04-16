using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using General.ErrorLogging.Model;
using System.Text.RegularExpressions;

namespace General.ErrorLogging.GUI.Controllers
{

    public class ApplicationController : ApiController
    {

        #region GetAll
        // GET api/Application
        [Authorize]
        public List<Application> GetAll(bool AddAnyOption = false)
        {
            var data = General.ErrorLogging.Data.Application.GetApplications();
            if(AddAnyOption)
            {
                var objAny = new Model.Application();
                objAny.AppIDString = "any";
                objAny.Name = "Any Application";
                data.Insert(0, objAny);
            }
            return data;
        }
        #endregion

        #region Get One
        // GET api/Application?ID=5
        [HttpGet]
        [Authorize]
        public object Get(int ID)
        {
            var app = General.ErrorLogging.Data.Application.GetApplication(ID);
            if (app == null)
                return "Application not found.";
            return app;
        }
        #endregion

    }
}