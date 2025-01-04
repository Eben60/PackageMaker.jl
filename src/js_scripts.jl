# # https://stackoverflow.com/questions/67895677/electron-problem-to-import-my-own-js-file

# in Electron window, no effect anyway, but could be useful
function checkonload(debug)
    debug || return ""

return """
<script type="text/javascript">
window.onload = function()
  {
      if (window.jQuery)
      {
          alert('jQuery is loaded');
      }
      else
      {
          alert('jQuery is not loaded');
      }
  };
</script>"""
end

debug::Bool = false

function js_scripts() 
    fpath = joinpath(@__DIR__, "javascript/jquery.js")
    jq = open(fpath, "r") do file
        read(file)
    end |> String
    
    js =
"""
<script>
$(jq)
</script>
<script>
function oncng(el) {
    sendel(el, "newinput");
};

$(make_dd_js_sel_lic())

function sendurl(url) {
  var reason = "external_link"
  Blink.msg("change", {reason: reason, url: url});
};

function sendel(el, reason) {
    var elid = el.id;
    var elval = el.value;
    var elchecked = null;
    var elclass = el.className
    var eltype = el.tagName.toLowerCase();
    var inputtype = el.type;
    if ("checked" in el) {elchecked = el.checked};
    var parentformid = parentForm_Id(el);
    Blink.msg("change", {reason: reason, elid: elid, elval: elval, elchecked: elchecked, elclass: elclass, parentformid: parentformid, eltype: eltype, inputtype: inputtype});
    // alert(el.id + " " + reason)
};

function parentForm_Id(el) {
  var parent = el.parentElement;
  var parenttype = parent.tagName;
  if (parenttype == null) {
    return null;
  } else {
    parenttype = parenttype.toLowerCase()
  };
  if (parenttype == "form") {
    return parent.id
  } else {
    return parentForm_Id(parent)
  };
};

function sendfullstate(isfinalstate, submit){
    // alert("sending full state")
    var reasoneach;
    var reasonfinl;
    if (isfinalstate) {
        //alert("finishing")
        reasoneach ="finalinput"
        if (submit) {reasonfinl ="finalinputfinished"}
        else {reasonfinl ="finalinputcancelled"}
   } else {
        reasoneach ="init_input"
        reasonfinl ="init_inputfinished"            
   }

    inps = document.querySelectorAll("input, textarea");
    for (el of inps) {
        sendel(el, reasoneach) ;
  };
  Blink.msg("change", {reason: reasonfinl});

  return null;
};

</script>

<script>
  jQuery(document).ready(function() {
    jQuery('.TogglePlugin').change(function() {
      if(jQuery(this).is(":checked")) {
        jQuery(this).siblings('.Plugin_Inputs').show();
      } else {
        jQuery(this).siblings('.Plugin_Inputs').hide();
      }
    });
  $(make_dd_act_menu())
  });
</script>
$(checkonload(debug))

"""
    return js
end