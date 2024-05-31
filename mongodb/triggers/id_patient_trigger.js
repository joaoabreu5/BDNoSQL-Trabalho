function stringify(object) {
    return JSON.stringify(object).replaceAll('"', "'").replaceAll(':', ': ').replaceAll(',', ', ');
}

exports = async function(changeEvent) {
    try {
        const fullDocument = changeEvent.fullDocument;
        const docId = changeEvent.documentKey._id;

        const clusterName = 'Cluster0';
        const databaseName = changeEvent.ns.db;
        const collectionName = changeEvent.ns.coll;
        const fieldName = 'id_patient';
        
        const countersCollName = 'counters'
        const countersFieldName = 'seq'
        const countersCollection = context.services.get(clusterName).db(databaseName).collection(countersCollName);
        
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
            const counter = await countersCollection.findOne(countersQuery, { [countersFieldName]: 1, _id: 0 });

            if (!counter || fieldValue > counter[countersFieldName]) {
                const oldCounterValue = (await countersCollection.findOneAndUpdate(
                    countersQuery, 
                    {
                        $set: { [countersFieldName]: fieldValue } 
                    }, 
                    { 
                        upsert: true,
                        projection: { [countersFieldName]: 1, _id: 0 }
                    }
                ))[countersFieldName];
                
                console.log(`Coleção '${countersCollName}': valor do campo '${countersFieldName}' do contador ${stringify(countersQuery)} atualizado de ${oldCounterValue} para ${fieldValue}.`);
            }
        }
        else if (operationType !== 'update') {    // operationType === 'insert' || operationType === 'replace'
            const newCounterValue = (await countersCollection.findOneAndUpdate(
                countersQuery,
                {
                    $inc: { [countersFieldName]: 1 }
                },
                {
                    returnNewDocument: true,
                    upsert: true,
                    projection: { [countersFieldName]: 1, _id: 0 }
                }
            ))[countersFieldName];

            console.log(`Coleção '${countersCollName}': valor do campo '${countersFieldName}' do contador ${stringify(countersQuery)} incrementado (em 1 unidade) para ${newCounterValue}.`);

            const documentCollection = context.services.get(clusterName).db(databaseName).collection(collectionName);
            const documentQuery = { _id: docId };

            await documentCollection.updateOne(documentQuery, { $set: { [fieldName]: newCounterValue } });

            console.log(`Coleção '${collectionName}': campo '${fieldName}' adicionado ao documento ${stringify(documentQuery)}, com valor igual a ${newCounterValue}.`);
        }

    } catch (err) {
        console.error('Erro ao executar o trigger: ', err.message);
    }
};
