import ballerina/http;
const central_url = "https://api.central.ballerina.io/2.0/registry";

http:Client centralClient = check new(central_url);

service /  on new http:Listener(9090) {
    resource function get [string pkg]/latestVersion() returns string|error {
        json[] versions = check centralClient->get(string`/packages/ballerinax/${pkg}`);
        return versions[0].toString();
    }

    resource function get [string pkg]/dependencies() returns json|error? {
        json[] versions = check centralClient->get(string`/packages/ballerinax/${pkg}`);
        json latestVersion = versions[0];
        json payload = {
            "packages": [
                {
                    "org": "ballerinax",
                    "name": pkg,
                    "version": latestVersion,
                    "mode": "medium"
                }
            ]
        };
        json deps = check centralClient->post("/packages/resolve-dependencies?level=-1", message = payload);
        json[] depsJson = <json[]>(check deps.resolved);
        return check depsJson[0].dependencyGraph;

    }
}
