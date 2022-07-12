-- FUNCTION: public.get_committee_label(text,text, text)
/*
This is for issue #4915.
This migration file creates database function: get_committee_label.
Based on cmte_type, cmte_dsgn and org_tp, to generate committee_label
*/
-- DROP FUNCTION public.get_committee_label(text,text, text);


CREATE OR REPLACE FUNCTION public.get_committee_label(
    cmte_type text,
    cmte_dsgn text,
    org_type text)
    RETURNS text
    LANGUAGE 'plpgsql'
AS $$
    begin
        return case 
            WHEN cmte_type = 'H' and cmte_dsgn = 'P' THEN 'House - principal campaign committee'
            WHEN cmte_type = 'H' and cmte_dsgn = 'A' THEN 'House - other authorized campaign committee'                       
            WHEN cmte_type = 'H' and COALESCE(cmte_dsgn, 'F') IN ('B', 'D', 'U', 'F') THEN 'House'
            WHEN cmte_type = 'S' and cmte_dsgn = 'P' THEN 'Senate - principal campaign committee'
            WHEN cmte_type = 'S' and cmte_dsgn = 'A' THEN 'Senate - other authorized campaign committee'                       
            WHEN cmte_type = 'S' and COALESCE(cmte_dsgn, 'F') IN ('B', 'D', 'U', 'F') THEN 'Senate'
            WHEN cmte_type = 'P' and cmte_dsgn = 'P' THEN 'President - principal campaign committee'
            WHEN cmte_type = 'P' and cmte_dsgn = 'A' THEN 'President - other authorized campaign committee'                       
            WHEN cmte_type = 'P' and COALESCE(cmte_dsgn, 'F') IN ('B', 'D', 'U', 'F') THEN 'President'
            WHEN cmte_type = 'D' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Delegate'     
            WHEN cmte_type = 'N' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'C' THEN 'Corporation PAC - nonqualifed'                        
            WHEN cmte_type = 'N' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'L' THEN 'Labor PAC - nonqualifed'                        
            WHEN cmte_type = 'N' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'T' THEN 'Trade PAC - nonqualifed'                                         
            WHEN cmte_type = 'N' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'M' THEN 'Membership PAC - nonqualifed'                        
            WHEN cmte_type = 'N' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'V' THEN 'Cooperative PAC - nonqualifed'                        
            WHEN cmte_type = 'N' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'W' THEN 'Corporation without stock PAC - nonqualifed'
            WHEN cmte_type = 'N' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') THEN 'PAC - nonqualifed'  
            WHEN cmte_type = 'Q' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'C' THEN 'Corporation PAC - qualified'                        
            WHEN cmte_type = 'Q' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'L' THEN 'Labor PAC - qualified'                        
            WHEN cmte_type = 'Q' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'T' THEN 'Trade PAC - qualified'                                         
            WHEN cmte_type = 'Q' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'M' THEN 'Membership PAC - qualified'                        
            WHEN cmte_type = 'Q' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'V' THEN 'Cooperative PAC - qualified'                        
            WHEN cmte_type = 'Q' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') and org_type = 'W' THEN 'Corporation without stock PAC - qualified'
            WHEN cmte_type = 'Q' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'P', 'U', 'F') THEN 'PAC - qualified'
            WHEN cmte_type = 'O' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Super PAC (Independent Expenditure-Only)'    
            WHEN cmte_type = 'U' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Single candidate independent expenditure' 
            WHEN cmte_type = 'V' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Hybrid PAC (with non-Contribution Account) - nonqualified'     
            WHEN cmte_type = 'W' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Hybrid PAC (with non-Contribution Account) - qualified' 
            WHEN cmte_type = 'N' and cmte_dsgn = 'D' THEN 'Leadership PAC - nonqualifed'
            WHEN cmte_type = 'Q' and cmte_dsgn = 'D' THEN 'Leadership PAC - qualified'
            WHEN cmte_type = 'X' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Party - nonqualifed'
            WHEN cmte_type = 'Y' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Party - qualified'
            WHEN cmte_type = 'Z' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Party nonfederal account'
            WHEN cmte_dsgn = 'J' THEN 'Joint fundraising'
            WHEN cmte_type = 'I' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Independent expenditures reported by persons other than a political committee'
            WHEN cmte_type = 'C' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') and org_type = 'C' THEN 'Communication cost - Corporation'                        
            WHEN cmte_type = 'C' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') and org_type = 'L' THEN 'Communication cost - Labor Organization'                        
            WHEN cmte_type = 'C' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') and org_type = 'T' THEN 'Communication cost - Trade Association'                                         
            WHEN cmte_type = 'C' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') and org_type = 'M' THEN 'Communication cost - Membership Organization'                        
            WHEN cmte_type = 'C' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') and org_type = 'V' THEN 'Communication cost - Cooperative'                        
            WHEN cmte_type = 'C' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') and org_type = 'W' THEN 'Communication cost - Corporation without Capital Stock'
            WHEN cmte_type = 'C' and org_type IS NULL THEN 'Communication cost'
            WHEN cmte_type = 'E' and COALESCE(cmte_dsgn, 'F') IN ('A', 'B', 'D', 'P', 'U', 'F') THEN 'Electioneering Communications' 
      ELSE 'UNKNOWN'
      end;
   end
$$;

ALTER FUNCTION public.get_committee_label(text,text, text)
    OWNER TO fec;
