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

    public class EventTypeController : ApiController
    {

        #region GetAll
        // GET api/EventType
        [Authorize]
        public IEnumerable<General.Reflection.EnumSerializer.EnumItem> GetAll(bool AddAnyOption = false)
        {
            var values = General.Reflection.EnumSerializer.Serialize<ErrorOtherTypes>();
            values = values.Where(row => row.IsDropDownListOption).ToList();
            if(AddAnyOption)
            {
                var objAny = new General.Reflection.EnumSerializer.EnumItem();
                objAny.Value = 0;
                objAny.Name = "Any Type";
                objAny.DisplayName = "Any Type";
                values.Insert(0, objAny);
            }
            return values;
        }
        #endregion

        #region Get One
        // GET api/EventType?ID=5
        [HttpGet]
        [Authorize]
        public string Get(int ID)
        {
            try
            {
                return ((ErrorOtherTypes)ID).ToString();
            }
            catch
            {
                return null;
            }
        }
        #endregion

    }
}