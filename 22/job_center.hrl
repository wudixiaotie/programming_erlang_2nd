-record (job_queue, {waitting = queue:new(),
                     processing = dict:new(),
                     done = [],
                     job_number = 1}).