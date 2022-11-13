include Redmine::Export::PDF
module AllTimeLogHelper

      ROW_HEIGHT    = 4

    def render_logo(pdf)
      # pdf.image( '/usr/src/redmine/public/plugin_assets/redmine_time_log_pdf_export/images/logo.png', 190,10, 20,10 )
      pdf.image( File.join(__dir__, '../assets/images/logo.png'), 140,10,50, 0 );
    end


      def render_final_sum(pdf,query)


        pdf.SetFontStyle('B',13)
        value = "Summe: " + query.results_scope.sum(:hours).to_s
        pdf.SetFillColor(240,240,240)
        pdf.RDMCell(30, ROW_HEIGHT * 1.5, value, 1, 0, 'L', 1)

        # query.columns.each do |column|
          # value = format_value_for_export(@query.entity, column, @entities.values.inject(0){|mem,var| (var[:sums] && var[:sums][:bottom]) ? mem += (var[:sums][:bottom][column] || 0).to_f : nil; mem })
          # value = query.results_scope.sum(column)
          # pdf.RDMCell(30, ROW_HEIGHT * 1.5, value, 1, 0, 'L', 1)
          # pdf.RDMCell(30, ROW_HEIGHT * 1.5, (column == query.columns.first ? l(:label_total_total) : ''), 1, 0, 'L', 1)
        # end
        pdf.ln
      end


    def timelogs_to_pdf(items, query, options={})
        columns = query.columns
        length=columns.length()

        case length.to_i

        when 1..6
            pdf = ITCPDF.new(current_language,"P")
            width=190
        when 7..9 
            pdf = ITCPDF.new(current_language,"L")
            width=200
        else
            pdf = ITCPDF.new(current_language,"L")
            width=255
        end
        
        pdf.set_title("MINKENBERG Zeitbericht")
        pdf.alias_nb_pages
        pdf.footer_date = format_date(User.current.today)
        pdf.add_page
        pdf.ln(5,1)
        pdf.SetFont('Helvetica','B')
        pdf.SetFontStyle('B',11)
        buf = "Bericht über gebuchte Stunden"
        pdf.SetFontStyle('',13)
        pdf.RDMCell(width, 5, buf,"","","C")
        pdf.ln(9,1)


        render_logo(pdf)

        base_x = pdf.get_x

        pdf.set_x(base_x)
        columns.each do |c| 
            pdf.set_text_color(255,255,255)
            pdf.SetFontStyle('B',8)
            if ((pdf.get_x).to_i > width)
                #pdf.ln(5,1)
                pdf.RDMCell(30,4,c.caption.to_s,1,"LRTB",1,1)
            else
                pdf.RDMCell(30,4,c.caption.to_s,1,'',1,1)
            end
        end

        pdf.set_text_color(32,32,32)
        pdf.ln(4,1)
        pdf.set_x(base_x)
       
        pdf.SetFontStyle('',8)

        details=Array.new
        items.each do |item|
            details << columns.map {|c| pdf_content(c, item)}
        end
        details.each do |detail|
            base_y = pdf.get_y
            max_height = 4
            detail.each do |d|
                col_x = pdf.get_x
                if ((pdf.get_x).to_i > width)
                    pdf.ln(5,1)
                    pdf.RDMMultiCell(30,4,d,'T','L',0)
                else
                    pdf.RDMMultiCell(30,4,d,'T','L',0)
                end
                max_height = (pdf.get_y - base_y) if (pdf.get_y - base_y) > max_height
                pdf.set_xy(col_x + 30,base_y)
            end
            pdf.set_y( base_y + max_height )
            pdf.ln(5,1)
        end

        render_final_sum(pdf,query)

        pdf.output
    end
end

