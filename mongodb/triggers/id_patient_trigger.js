exports = async function(changeEvent) {
    try {
        const fullDocument = changeEvent.fullDocument;
        const docId = changeEvent.documentKey._id

        const clusterName = 'Cluster0';
        const databaseName = changeEvent.ns.db;
        const collectionName = changeEvent.ns.coll;
        const fieldName = 'id_patient';
        
        const countersCollection = context.services.get(clusterName).db(databaseName).collection('counters');
        const countersQuery = { field: fieldName, col: collectionName };
        
        let fieldValue;
        const operationType = changeEvent.operationType;

        if (operationType === 'update') {
            fieldValue = changeEvent.updateDescription.updatedFields[fieldName];
        }
        else {    // operationType === 'insert' || operationType === 'replace'
            fieldValue = fullDocument[fieldName];
        }

        if (fieldValue) {
            const counter = await countersCollection.findOne(countersQuery, { seq: 1, _id: 0 });

            if (!counter || fieldValue > counter.seq) {
                await countersCollection.updateOne(countersQuery, { $set: { seq: fieldValue } }, { upsert: true });
            }
        }
        else if (operationType !== 'update') {    // operationType === 'insert' || operationType === 'replace'
            const newCounterValue = (await countersCollection.findOneAndUpdate(
                countersQuery,
                {
                    $inc: { seq: 1 }
                },
                {
                    returnNewDocument: true,
                    upsert: true,
                    projection: { seq: 1, _id: 0 }
                }
            )).seq;

            const patientsCollection = context.services.get(clusterName).db(databaseName).collection(collectionName);

            await patientsCollection.updateOne({ _id: docId }, { $set: { [fieldName]: newCounterValue } });
        }

        console.log(`Successfully processed the trigger for '${fieldName}' counter.`);
        
    } catch (err) {
        console.error('Failed to process the trigger: ', err.message);
    }
};
