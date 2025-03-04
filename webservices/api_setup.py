import flask_restful as restful
from flask import Blueprint

from webservices.resources import national_party
from webservices.resources import totals
from webservices.resources import reports
from webservices.resources import sched_a
from webservices.resources import sched_b
from webservices.resources import sched_c
from webservices.resources import sched_d
from webservices.resources import sched_e
from webservices.resources import sched_f
from webservices.resources import sched_h4
from webservices.resources import download
from webservices.resources import aggregates
from webservices.resources import candidate_aggregates
from webservices.resources import candidates
from webservices.resources import committees
from webservices.resources import elections
from webservices.resources import filings
from webservices.resources import rad_analyst
from webservices.resources import search
from webservices.resources import dates
from webservices.resources import costs
from webservices.resources import legal
from webservices.resources import large_aggregates
from webservices.resources import audit
from webservices.resources import operations_log
from webservices.resources import presidential
from webservices.resources import spending_by_others
from webservices.env import env


from webservices.common import util

v1 = Blueprint('v1', __name__, url_prefix='/v1')
api = restful.Api(v1)
api.representations['application/json'] = util.output_json
SHOW_TEST_F1 = env.get_credential('FEC_SHOW_TEST_F1', False)


api.add_resource(national_party.NationalParty_ScheduleAView, '/national_party/schedule_a/')
api.add_resource(national_party.NationalParty_ScheduleBView, '/national_party/schedule_b/')
api.add_resource(national_party.NationalPartyTotalsView, '/national_party/totals/')
api.add_resource(candidates.CandidateList, '/candidates/')
api.add_resource(candidates.CandidateSearch, '/candidates/search/')
api.add_resource(
    candidates.CandidateView,
    '/candidate/<string:candidate_id>/',
    '/committee/<string:committee_id>/candidates/',
)
api.add_resource(
    candidates.CandidateHistoryView,
    '/candidate/<string:candidate_id>/history/',
    '/candidate/<string:candidate_id>/history/<int:cycle>/',
    '/committee/<string:committee_id>/candidates/history/',
    '/committee/<string:committee_id>/candidates/history/<int:cycle>/',
)
api.add_resource(committees.CommitteeList, '/committees/')
api.add_resource(
    committees.CommitteeView,
    '/committee/<string:committee_id>/',
    '/candidate/<string:candidate_id>/committees/',
)
api.add_resource(
    committees.CommitteeHistoryProfileView,
    '/committee/<string:committee_id>/history/',
    '/committee/<string:committee_id>/history/<int:cycle>/',
    '/candidate/<string:candidate_id>/committees/history/',
    '/candidate/<string:candidate_id>/committees/history/<int:cycle>/',
)
api.add_resource(totals.TotalsByEntityTypeView, '/totals/<string:entity_type>/')
api.add_resource(totals.TotalsCommitteeView, '/committee/<string:committee_id>/totals/')
api.add_resource(totals.CandidateTotalsDetailView, '/candidate/<string:candidate_id>/totals/')
api.add_resource(reports.ReportsView, '/reports/<string:entity_type>/')
api.add_resource(reports.CommitteeReportsView, '/committee/<string:committee_id>/reports/')
api.add_resource(search.CandidateNameSearch, '/names/candidates/')
api.add_resource(search.CommitteeNameSearch, '/names/committees/')
api.add_resource(sched_a.ScheduleAView, '/schedules/schedule_a/', '/schedules/schedule_a/<string:sub_id>/')
api.add_resource(sched_a.ScheduleAEfileView, '/schedules/schedule_a/efile/')
api.add_resource(sched_b.ScheduleBView, '/schedules/schedule_b/', '/schedules/schedule_b/<string:sub_id>/')
api.add_resource(sched_b.ScheduleBEfileView, '/schedules/schedule_b/efile/')
api.add_resource(sched_c.ScheduleCView, '/schedules/schedule_c/')
api.add_resource(sched_c.ScheduleCViewBySubId, '/schedules/schedule_c/<string:sub_id>/')
api.add_resource(sched_d.ScheduleDView, '/schedules/schedule_d/')
api.add_resource(sched_d.ScheduleDViewBySubId, '/schedules/schedule_d/<string:sub_id>/')
api.add_resource(sched_e.ScheduleEView, '/schedules/schedule_e/')
api.add_resource(sched_e.ScheduleEEfileView, '/schedules/schedule_e/efile/')
api.add_resource(sched_f.ScheduleFView, '/schedules/schedule_f/', '/schedules/schedule_f/<string:sub_id>/')
api.add_resource(sched_f.ScheduleFViewBySubId, '/schedules/schedule_f/<string:sub_id>/')
api.add_resource(sched_h4.ScheduleH4View, '/schedules/schedule_h4/')
api.add_resource(sched_h4.ScheduleH4EfileView, '/schedules/schedule_h4/efile/')
api.add_resource(costs.CommunicationCostView, '/communication_costs/')
api.add_resource(costs.ElectioneeringView, '/electioneering/')
api.add_resource(elections.ElectionView, '/elections/')
api.add_resource(elections.ElectionsListView, '/elections/search/')
api.add_resource(elections.ElectionSummary, '/elections/summary/')
api.add_resource(elections.StateElectionOfficeInfoView, '/state-election-office/')
api.add_resource(dates.ElectionDatesView, '/election-dates/')
api.add_resource(dates.ReportingDatesView, '/reporting-dates/')
api.add_resource(dates.CalendarDatesView, '/calendar-dates/')
api.add_resource(dates.CalendarDatesExport, '/calendar-dates/export/')
api.add_resource(rad_analyst.RadAnalystView, '/rad-analyst/')
api.add_resource(filings.EFilingsView, '/efile/filings/')
api.add_resource(filings.F2EFilingsView, '/efile/form2/')
api.add_resource(filings.F1EFilingsView, '/efile/form1/')
api.add_resource(large_aggregates.EntityReceiptDisbursementTotalsView, '/totals/by_entity/')
api.add_resource(audit.AuditPrimaryCategoryView, '/audit-primary-category/')
api.add_resource(audit.AuditCategoryView, '/audit-category/')
api.add_resource(audit.AuditCaseView, '/audit-case/')
api.add_resource(audit.AuditCandidateNameSearch, '/names/audit_candidates/')
api.add_resource(audit.AuditCommitteeNameSearch, '/names/audit_committees/')
api.add_resource(aggregates.ScheduleABySizeView, '/schedules/schedule_a/by_size/')
api.add_resource(aggregates.ScheduleAByStateView, '/schedules/schedule_a/by_state/')
api.add_resource(aggregates.ScheduleAByZipView, '/schedules/schedule_a/by_zip/')
api.add_resource(aggregates.ScheduleAByEmployerView, '/schedules/schedule_a/by_employer/')
api.add_resource(aggregates.ScheduleAByOccupationView, '/schedules/schedule_a/by_occupation/')
api.add_resource(aggregates.ScheduleBByRecipientView, '/schedules/schedule_b/by_recipient/')
api.add_resource(aggregates.ScheduleBByRecipientIDView, '/schedules/schedule_b/by_recipient_id/')
api.add_resource(aggregates.ScheduleBByPurposeView, '/schedules/schedule_b/by_purpose/')
api.add_resource(aggregates.ScheduleEByCandidateView, '/schedules/schedule_e/by_candidate/')
api.add_resource(candidate_aggregates.ScheduleABySizeCandidateView, '/schedules/schedule_a/by_size/by_candidate/')
api.add_resource(candidate_aggregates.ScheduleAByStateCandidateView, '/schedules/schedule_a/by_state/by_candidate/')
api.add_resource(candidate_aggregates.ScheduleAByStateCandidateTotalsView,
                 '/schedules/schedule_a/by_state/by_candidate/totals/')
api.add_resource(candidate_aggregates.TotalsCandidateView, '/candidates/totals/')
api.add_resource(totals.ScheduleAByStateRecipientTotalsView, '/schedules/schedule_a/by_state/totals/')
api.add_resource(candidate_aggregates.CandidateTotalAggregateView, '/candidates/totals/aggregates/')
api.add_resource(totals.InauguralDonationsView, '/totals/inaugural_committees/by_contributor/')


api.add_resource(
    aggregates.CommunicationCostByCandidateView,
    '/communication_costs/by_candidate/',
)

api.add_resource(
    aggregates.CCAggregatesView,
    '/communication_costs/aggregates/',
)

api.add_resource(
    aggregates.ElectioneeringByCandidateView,
    '/electioneering/by_candidate/',
)

api.add_resource(
    aggregates.ECAggregatesView,
    '/electioneering/aggregates/',
)

api.add_resource(
    spending_by_others.ECTotalsByCandidateView,
    '/electioneering/totals/by_candidate/',
)

api.add_resource(
    spending_by_others.IETotalsByCandidateView,
    '/schedules/schedule_e/totals/by_candidate/',
)

api.add_resource(
    spending_by_others.CCTotalsByCandidateView,
    '/communication_costs/totals/by_candidate/',
)

api.add_resource(
    filings.FilingsView,
    '/committee/<committee_id>/filings/',
    '/candidate/<candidate_id>/filings/',
)

api.add_resource(
    reports.EFilingHouseSenateSummaryView,
    '/efile/reports/house-senate/',
)

api.add_resource(
    reports.EFilingPresidentialSummaryView,
    '/efile/reports/presidential/',
)

api.add_resource(
    reports.EFilingPacPartySummaryView,
    '/efile/reports/pac-party/',
)

api.add_resource(filings.FilingsList, '/filings/')
api.add_resource(download.DownloadView, '/download/<path:path>/')
api.add_resource(legal.UniversalSearch, '/legal/search/')
api.add_resource(legal.GetLegalCitation, '/legal/citation/<citation_type>/<citation>')
api.add_resource(legal.GetLegalDocument, '/legal/docs/<doc_type>/<no>')
api.add_resource(operations_log.OperationsLogView, '/operations-log/')
api.add_resource(presidential.PresidentialByCandidateView, '/presidential/contributions/by_candidate/')
api.add_resource(presidential.PresidentialSummaryView, '/presidential/financial_summary/')
api.add_resource(presidential.PresidentialBySizeView, '/presidential/contributions/by_size/')
api.add_resource(presidential.PresidentialByStateView, '/presidential/contributions/by_state/')
api.add_resource(presidential.PresidentialCoverageView, '/presidential/coverage_end_date/')
if SHOW_TEST_F1:
    api.add_resource(filings.TestF1EFilingsView, '/efile/test-form1/')
