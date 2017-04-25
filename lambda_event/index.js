exports.handler = function (event, context, callback) {

    // All these libraries need to be in package.json
    var os = require("os");
    var Intercom = require('intercom-client');

    // process.env accesses environment variables defined in Lambda function
    // This is more secure then adding them to the code for the lambda function
    var client = new Intercom.Client({ token:  process.env.intercom_at});
    // The admin ID to send the message from
    var admin_id = process.env.admin_id;

    // The event data structure holds all the data you need
    // It is passed through by the API gateway to the lambda function
    // So we can just get the pieces we need here
    var event_name = JSON.stringify(event.data.item.event_name)
    var customer = event.data.item.user_id
    var driver_name = JSON.stringify(event.data.item.metadata.driver_name)
    var location = JSON.stringify(event.data.item.metadata.location)

    console.log("USER_ID: " + customer)
    console.log("ADMIN_ID: " + admin_id)
    console.log("AT: " + process.env.intercom_at)
    /* Create an admin initiated msg for the person who ordered the taxi
     *  You know from the event metadata their Intercom user_id and the
     *  driver id and name so tell them this information so they know who
     *  to expect and to confirm the journey */
    var message = {
        message_type: "inapp",
	body: `Thank you for choosing unter \nYour drive has been confirmed and your drivers name is ${driver_name}\nYour driver will pick you up at ${location}`,
        from: {
            type: "admin",
            id: admin_id
        },
        to: {
            type: "user",
            user_id: customer
        }
    };

    client.messages.create(message, function (rsp){
        console.log(rsp.body)
    });

    var responseBody = {
        message: event_name,
        input: event
    };
    var response = {
        statusCode: "200",
        headers: {
            "x-custom-header" : "Lambda function: Event"
        },
        body: JSON.stringify(responseBody)
    };
    console.log("response: " + JSON.stringify(response))
    callback(null, response);
}
