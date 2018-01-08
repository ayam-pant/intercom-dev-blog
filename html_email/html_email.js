var Intercom = require('intercom-client');

var client = new Intercom.Client({ token: process.env['AT'] });

// First let's send an email with some example HTML format in the body
var message = {
    message_type: "email",
    subject: "Test HTML email messages",
    template: 'personal',
    "body": "\ " +
    "<html> \ " +
        "<body> \ " +
            "<h1> \ " +
                "<b> This is bold heading </b>\ " +
            "</h1> " +
            "<p>This is a <mark>marked</mark> <br> \ " +
                "and <ins>underscored</ins> <br> \ " +
                "paragraph with <i>itallics</i>  <br> \ " +
                "and a <a href='intercom.io'>link </a> " +
            "</p> \ " +
            "<h2> \ " +
                "This is an Unordered HTML List \ " +
            "</h2> \ " +
                "<ul> \ " +
                    "<li>Coffee</li> \ " +
                    "<li>Tea</li>  \ " +
                    "<li>Milk</li> \ " +
                "</ul> \ " +
            "<h2> \ " +
                "An Ordered HTML List \ " +
            "</h2> \ " +
            "<ol> \ " +
                "<li>Coffee</li> \ " +
                "<li>Tea</li>  \ " +
                "<li>Milk</li> \ " +
            "</ol> \ " +
            "This is a table \ " +
            "<table border='1'> \ " +
                "<tr> \ " +
                    "<th>Month</th> \ " +
                    "<th>Savings</th> \ " +
                "</tr> \ " +
                "<tr> \ " +
                    "<td>January</td> \ " +
                    "<td>$100</td> \ " +
                "</tr> \ " +
                "<tr> \ " +
                    "<td>February</td> \ " +
                    "<td>$80</td>  \ " +
                "</tr> \ " +
            "</table> \ " +
            "and an image <br> \ " +
            "<img src = 'http://getstartedhq.com/wp-content/uploads/2017/05/iWpbzpjL.png' \ " +
                "alt = 'No images found' height = '150'' width = '130' /> \ " +
        "</body> \ " +
    "</html>",
    from: {
        type: "admin",
        id: "814860"
    },
    to: {
        type: "contact",
        id: "599d6aeeda850883ed8ba7c2"
    }
}

function adminEmailMsg() {
    console.log("Send an admin initiated email message to a lead")
    client.messages.create(message, function (rsp){
        console.log(rsp.body)
    });
}


// Now that we have send the email let us check if we can find the conversation
function getConvoList(rsp) {
    console.log("Retrieve the conversations for the app with paging")
    if (rsp) {
        rsp.body.conversations.forEach(function(convo){
            console.log(convo.conversation_message.id)
        });
        if (rsp.body.pages.next) {
            client.nextPage(rsp.body.pages, function(rsp){
                console.log("in rsp call");
                getConvoList(rsp)
            });
        }
    } else {
        client.conversations.list({}, function (rsp){
            rsp.body.conversations.forEach(function(convo){
                console.log(convo.conversation_message.id)
            });
            if (rsp.body.pages.next) {
                getConvoList(rsp)
            }
        });
    }
}

function getUserMsgIDs(userId) {
    console.log("Retrieve the list of conversations for this user (no paging)")
    // Now that we have send the email let us check if we can find the conversation
    client.conversations.list({type: 'user', intercom_user_id: userId}, function (rsp){
        rsp.body.conversations.forEach(function(convo){
            console.log(convo.conversation_message.id)
        });
    });
}

function getAllConvoList() {
    console.log("List the most recently updated conversations")
    // Now that we have send the email let us check if we can find the conversation
    client.conversations.list({sort: 'waiting_since', order: 'desc'}, function (rsp){
        console.log(rsp.body)
    });
}

function getUserConvoList(userId) {
    console.log("List the most recently created customer conversations")
    // Now that we have send the email let us check if we can find the conversation
    client.conversations.list({type: 'user', intercom_user_id: userId, sort: 'desc', order: 'created_at'}, function (rsp){
        console.log(rsp.body)
    });
}

function getAdminConvoList(adminId) {
    console.log("Retrieve the list of conversations for this admin (no paging)")
    // Now that we have send the email let us check if we can find the conversation
    client.conversations.list({type: 'admin', admin_id: adminId, sort: 'desc', order: 'updated_at'}, function (rsp){
        console.log(rsp.body)
    });
}

//setTimeout(getConvoList, 3000);
function getSingleConversation(convoId) {
    client.conversations.find({ id: convoId }, function (rsp){
        console.log(rsp.body)
    });
}

// Fetch a conversation
function getSingleConvo(convo_id){
    client.conversations.find({ id: convo_id }, function (rsp) {
        console.log(rsp.body)
    });
}

