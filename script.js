import http from "k6/http";
import { check, sleep } from "k6";
import { Trend, Rate } from "k6/metrics";

// for each endpoint
//const CandidateTotalsErrorRate = new Rate('CandidateTotals errors');
//const AuditCaseErrorRate = new Rate('audit-case errors');

//const CandidateTotalsTrend = new Trend('CandidateTotals');
//const AuditCase = new Trend('audit-case');

const legalErrorRate = new Rate("legal errors");
const legalTrend = new Trend("legal");

export const options = {
  //    vus: 400,
  //    duration: '2.5m',
  //    batch: 15, //maximum number of simultaneous/parallel connections
  thresholds: {
    http_req_failed: ["rate<0.01"], // http errors should be less than 1%
    //   'CandidateTotals': ['p(95)<500'], // 95% of requests should be below 500ms
    //   'audit-case': ['p(95)<800'] // 95% of requests should be below 500ms
  },
  // scenarios: {
  //   constant_request_rate: {
  //   executor: 'constant-arrival-rate',
  //     rate: 3,
  //     timeUnit: '1s',
  //     duration: '3m',
  //     preAllocatedVUs: 20,
  //    maxVUs: 400,
  //  },
  // },
  stages: [
    { duration: "5m", target: 150 }, // traffic ramp-up from 1 to a higher 200 users over 10 minutes.
    { duration: "15m", target: 150 }, // stay at higher 200 users for 10 minutes
    { duration: "3m", target: 0 }, // ramp-down to 0 users
  ],
};

export default function () {
  const baseURL = "https://fec-dev-api.app.cloud.gov/v1/";
  const test_candidate = "P80001571";

  const params = { api_key: "" };
  const requests = {
    legal: {
      method: "GET",
      url: baseURL + "legal/" + "search/",
      params: params + { ao_no: "2019-14" },
    },
    //'legal': {
    //  method: 'GET',
    //  url: baseURL + 'candidate/' + test_candidate + '/totals/',
    //  params: params + {'sort': '-cycle'} ,
    // },
    // 'audit-case': {
    //   method: 'GET',
    //   url: baseURL + 'audit-case/',
    //   params: params + {'primary_category_id': 'all',
    // 'sub_category_id': 'all',
    // 'sort': '-cycle',
    // 'sort': 'committee_name'}
  }; //,
  // };

  const responses = http.batch(requests);
  // const CandidateTotalsResp = responses['CandidateTotals'];
  // const auditCaseResp = responses['audit-case'];
  const legalResp = responses["legal"];

  check(legalResp, {
    "status is 200": (r) => r.status === 200,
  }) || legalErrorRate.add(1);

  legalTrend.add(legalResp.timings.duration);

  //check(auditCaseResp, {
  //  'status is 200': (r) => r.status === 200,
  //}) || AuditCaseErrorRate.add(1);

  //AuditCase.add(auditCaseResp.timings.duration);

  sleep(1);
}
