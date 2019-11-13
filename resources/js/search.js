$(document).ready(function () {
    "use strict";

    //place to load resources if needed
/*
    $('#search').submit(function(e){
        e.preventDefault();
    });
*/
});


function serializeForm(){

    var result = {};
    var names = $('#search [name]');

    $('#search [name]').each(function(idx){
        if(this.nodeName.toLowerCase() == 'div'){
            var n = this.getAttribute('name');
            if(!result[n]){
                result[n] = [];
            }

            // do we have children with 'name' attributes?
            if($(this).find('[name]').length){

                var repeatitems = $(this).find('[name]');
                var o ={};
                for(var i=0; i < repeatitems.length; i++){

                    // console.log('current element: ', repeatitems[i]);
                    // console.log('current element: ', repeatitems[i].checked);

                    var name = $(repeatitems[i]).attr('name');
                    // var v = $(repeatitems[i]).val();
                    var v = _getValue(repeatitems[i]);
                    o[name] = v;
                }
                // console.log('result obj ', o);
                // console.log('result obj json ', JSON.stringify(o));
                // console.log('result[n] ', result[n]);

                result[n].push(o);

            }

        }else {
            //check if not inside of a div (repeat) already
            if(!this.closest('div[name]')){
                var name = this.getAttribute('name');
                var val;
                if(this.value){
                    val = this.value;
                }else{
                    val = "";
                }
                result[name] = val;
            }
        }
    });

    console.log("result ", result);
    console.log("result ", JSON.stringify(result));

    $.ajax({
        url:'name-search',
        data : JSON.stringify(result),
        dataType:'json',
        type : 'POST'
    });
}

function appendItem(item){
    console.log('appendItem ', item);
    var template = document.getElementById(item);
    var clone = document.importNode(template.content, true);
    template.parentNode.appendChild(clone);
}

function _getValue(elem) {
    if(elem.type == 'checkbox'){
        return elem.checked;
    }else{
        return elem.value;
    }
}
/*
{
    "name":"",
    "name-context":"all",
    "dialect-boolean":"and",
    "dialect":[
        {"dialect-checkbox": "on", "dialect-value": "attic"},
        {"dialect-checkbox": "off", "dialect-value": "bar"}
    ],
    "dialect-checkbox":"on",
    "dialect-value":"attic"
}
*/

