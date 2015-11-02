function v_ia_adim = v_ia_adim(v_z_adim)

if v_z_adim<=-2
    v_ia_adim = -1/2*( v_z_adim + sqrt((v_z_adim)^2-4)  );
elseif v_z_adim>-2 && v_z_adim<0
    v_ia_adim = ( 1-1/2*v_z_adim+25/12*(v_z_adim)^2+7/6*(v_z_adim)^3 );
    
elseif v_z_adim >= 0
    v_ia_adim = 1/2*( -v_z_adim + sqrt((v_z_adim)^2+4) );
else
    v_ia_adim = 0;
end

end