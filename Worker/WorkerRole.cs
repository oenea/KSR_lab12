using System;
using System.Diagnostics;
using System.Net;
using System.Threading;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Azure.Storage.Queues;
using Microsoft.WindowsAzure.ServiceRuntime;

namespace Worker
{
    // CMD: & "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\WcfTestClient.exe"
    public class WorkerRole : RoleEntryPoint
    {
        private readonly CancellationTokenSource _cancellationTokenSource = new CancellationTokenSource();
        private readonly ManualResetEvent _runCompleteEvent = new ManualResetEvent(false);

        private const string StorageConnectionString = "UseDevelopmentStorage=true";
        private const string QueueName = "jobs";
        private const string EncodedBlobContainerName = "encodedData";
        private const string BlobContainerName = "inputData";

        public override void Run()
        {
            Trace.TraceInformation("Worker is running");

            try { RunAsync(_cancellationTokenSource.Token).Wait(); }
            finally { _runCompleteEvent.Set(); }
        }

        public override bool OnStart()
        {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            ServicePointManager.DefaultConnectionLimit = 100;

            var result = base.OnStart();
            Trace.TraceInformation("Worker has been started");

            return result;
        }

        public override void OnStop()
        {
            Trace.TraceInformation("Worker is stopping");

            _cancellationTokenSource.Cancel();
            _runCompleteEvent.WaitOne();

            base.OnStop();

            Trace.TraceInformation("Worker has stopped");
        }

        private async Task RunAsync(CancellationToken cancellationToken)
        {
            Trace.TraceInformation("Worker logic started");

            var queueClient = new QueueClient(StorageConnectionString, QueueName);
            await queueClient.CreateIfNotExistsAsync(cancellationToken: cancellationToken);

            var blobServiceClient = new BlobServiceClient(StorageConnectionString);
            var inputContainer = blobServiceClient.GetBlobContainerClient(BlobContainerName);
            var encodedContainer = blobServiceClient.GetBlobContainerClient(EncodedBlobContainerName);
            await inputContainer.CreateIfNotExistsAsync(cancellationToken: cancellationToken);
            await encodedContainer.CreateIfNotExistsAsync(cancellationToken: cancellationToken);

            var rnd = new Random();

            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    var msgResponse = await queueClient.ReceiveMessageAsync(cancellationToken: cancellationToken);
                    var msg = msgResponse.Value;
                    if (msg != null)
                    {
                        var nazwa = msg.Body.ToString();
                        var done = false;

                        while (!done && !cancellationToken.IsCancellationRequested)
                        {
                            try
                            {
                                var blobClient = inputContainer.GetBlobClient(nazwa);
                                if (!await blobClient.ExistsAsync(cancellationToken))
                                {
                                    Trace.TraceWarning($"Blob {nazwa} does not exist.");
                                    break;
                                }
                                var data = (await blobClient.DownloadContentAsync(cancellationToken)).Value.Content.ToString();

                                if (rnd.Next(3) == 0) throw new Exception("Random ROT13 error!");

                                var encoded = Rot13(data);

                                var encodedBlobClient = encodedContainer.GetBlobClient(nazwa);
                                await encodedBlobClient.UploadAsync(BinaryData.FromString(encoded), overwrite: true, cancellationToken: cancellationToken);

                                done = true;
                                Trace.TraceInformation($"Blob {nazwa} encoded and saved.");
                            }
                            catch (Exception ex)
                            {
                                Trace.TraceWarning($"Error encoding blob {nazwa}: {ex.Message}. Retrying...");
                                await Task.Delay(1000, cancellationToken);
                            }
                        }
                        await queueClient.DeleteMessageAsync(msg.MessageId, msg.PopReceipt, cancellationToken);
                    }
                    else { await Task.Delay(1000, cancellationToken); }
                }
                catch (TaskCanceledException) { break; }
                catch (Exception ex)
                {
                    Trace.TraceError($"Worker exception: {ex.Message}");
                    await Task.Delay(2000, cancellationToken);
                }
            }

            Trace.TraceInformation("Worker logic ended");
        }

        private static string Rot13(string input)
        {
            char[] arr = input.ToCharArray();
            for (int i = 0;
            i < arr.Length;
            i++)
            {
                int chr = arr[i];
                if (chr >= 97 && chr <= 122)
                    arr[i] = (char)((97 + (chr - 97 + 13) % 26));
                else if (chr >= 65 && chr <= 90)
                    arr[i] = (char)((65 + (chr - 65 + 13) % 26));
            }
            return new string(arr);
        }
    }
}
