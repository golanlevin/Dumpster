"use strict";
/*****************************************
 * vororelax                             *
 *****************************************/
/* Compiled by WAXC (Version Nov  6 2020)*/
var vororelax;
(function (vororelax) {
    /*=== WAX Standard Library BEGIN ===*/
    const w_slice = (x, i, n) => x.slice(i, i + n);
    /*=== WAX Standard Library END   ===*/
    /*=== User Code            BEGIN ===*/
    const acos = Math.acos;
    const asin = Math.asin;
    const atan = Math.atan;
    const cos = Math.cos;
    const sin = Math.sin;
    const tan = Math.tan;
    const exp = Math.exp;
    const log = Math.log;
    const sqrt = Math.sqrt;
    const ceil = Math.ceil;
    const floor = Math.floor;
    const fabs = Math.abs;
    const fmin = Math.min;
    const fmax = Math.max;
    const atan2 = Math.atan2;
    const pow = Math.pow;
    const abs = Math.abs;
    const round = Math.round;
    const random = Math.random;
    const INFINITY = Infinity;
    // @ts-ignore
    const sinh = Math.sinh;
    // @ts-ignore
    const cosh = Math.cosh;
    // @ts-ignore
    const tanh = Math.tanh;
    function circumcircle(xp, yp, x1, y1, x2, y2, x3, y3, xcycr) {
        let m1 = 0.0;
        let m2 = 0.0;
        let mx1 = 0.0;
        let mx2 = 0.0;
        let my1 = 0.0;
        let my2 = 0.0;
        let dx = 0.0;
        let dy = 0.0;
        let drsqr = 0.0;
        let fabsy1y2 = 0.0;
        fabsy1y2 = fabs(((y1) - (y2)));
        let fabsy2y3 = 0.0;
        fabsy2y3 = fabs(((y2) - (y3)));
        let xc = 0.0;
        let yc = 0.0;
        let rsqr = 0.0;
        if (((Number((fabsy1y2) < (0.0000001))) && (Number((fabsy2y3) < (0.0000001))))) {
            return 0;
        }
        ;
        if (Number((fabsy1y2) < (0.0000001))) {
            m2 = ((0.0) - (((((x3) - (x2))) / (((y3) - (y2))))));
            mx2 = ((((x2) + (x3))) / (2.0));
            my2 = ((((y2) + (y3))) / (2.0));
            xc = ((((x2) + (x1))) / (2.0));
            yc = ((((m2) * (((xc) - (mx2))))) + (my2));
        }
        else {
            if (Number((fabsy2y3) < (0.0000001))) {
                m1 = ((0.0) - (((((x2) - (x1))) / (((y2) - (y1))))));
                mx1 = ((((x1) + (x2))) / (2.0));
                my1 = ((((y1) + (y2))) / (2.0));
                xc = ((((x3) + (x2))) / (2.0));
                yc = ((((m1) * (((xc) - (mx1))))) + (my1));
            }
            else {
                m1 = ((0.0) - (((((x2) - (x1))) / (((y2) - (y1))))));
                m2 = ((0.0) - (((((x3) - (x2))) / (((y3) - (y2))))));
                mx1 = ((((x1) + (x2))) / (2.0));
                mx2 = ((((x2) + (x3))) / (2.0));
                my1 = ((((y1) + (y2))) / (2.0));
                my2 = ((((y2) + (y3))) / (2.0));
                xc = ((((((((((m1) * (mx1))) + (((0.0) - (((m2) * (mx2))))))) + (my2))) + (((0.0) - (my1))))) / (((m1) - (m2))));
                if (Number((fabsy1y2) > (fabsy2y3))) {
                    yc = ((((m1) * (((xc) - (mx1))))) + (my1));
                }
                else {
                    yc = ((((m2) * (((xc) - (mx2))))) + (my2));
                }
                ;
            }
            ;
        }
        ;
        dx = ((x2) - (xc));
        dy = ((y2) - (yc));
        rsqr = ((((dx) * (dx))) + (((dy) * (dy))));
        dx = ((xp) - (xc));
        dy = ((yp) - (yc));
        drsqr = ((((dx) * (dx))) + (((dy) * (dy))));
        ((xcycr)[0] = xc);
        ((xcycr)[1] = yc);
        ((xcycr)[2] = rsqr);
        return Number((((drsqr) - (rsqr))) <= (0.0000001));
    }
    vororelax.circumcircle = circumcircle;
    ;
    function delaunaytriangulate(pxyz) {
        let nv = 0;
        nv = pxyz.length;
        let inside = 0;
        let xp = 0.0;
        let yp = 0.0;
        let x1 = 0.0;
        let y1 = 0.0;
        let x2 = 0.0;
        let y2 = 0.0;
        let x3 = 0.0;
        let y3 = 0.0;
        let xmin = 0.0;
        let xmax = 0.0;
        let ymin = 0.0;
        let ymax = 0.0;
        let xmid = 0.0;
        let ymid = 0.0;
        let dx = 0.0;
        let dy = 0.0;
        let dmax = 0.0;
        let xcycr = null;
        xcycr = (new Array(3)['fill'](0.0));
        let complete = null;
        complete = [];
        let v = null;
        v = [];
        if (Number((pxyz.length) < (3))) {
            /*GC*/ complete = null;
            /*GC*/ xcycr = null;
            return v;
        }
        ;
        xmin = ((((pxyz)[0]))[0]);
        ymin = ((((pxyz)[0]))[1]);
        xmax = xmin;
        ymax = ymin;
        for (let i = (1); Number((i) < (nv)); i += (1)) {
            if (Number((((((pxyz)[i]))[0])) < (xmin))) {
                xmin = ((((pxyz)[i]))[0]);
            }
            ;
            if (Number((((((pxyz)[i]))[0])) > (xmax))) {
                xmax = ((((pxyz)[i]))[0]);
            }
            ;
            if (Number((((((pxyz)[i]))[1])) < (ymin))) {
                ymin = ((((pxyz)[i]))[1]);
            }
            ;
            if (Number((((((pxyz)[i]))[1])) > (ymax))) {
                ymax = ((((pxyz)[i]))[1]);
            }
            ;
        }
        ;
        dx = ((xmax) - (xmin));
        dy = ((ymax) - (ymin));
        dmax = ((Number((dx) > (dy))) ? (dx) : (dy));
        xmid = ((((xmax) + (xmin))) / (2));
        ymid = ((((ymax) + (ymin))) / (2));
        (pxyz).splice((pxyz.length), 0, ([(((xmid) - (((2.0) * (dmax))))), (((ymid) - (dmax)))]));
        (pxyz).splice((pxyz.length), 0, ([(xmid), (((ymid) + (((2.0) * (dmax)))))]));
        (pxyz).splice((pxyz.length), 0, ([(((xmid) + (((2.0) * (dmax))))), (((ymid) - (dmax)))]));
        (v).splice((0), 0, ([(nv), (((nv) + (1))), (((nv) + (2)))]));
        (complete).splice((0), 0, (0));
        for (let i = (0); Number((i) < (nv)); i += (1)) {
            xp = ((((pxyz)[i]))[0]);
            yp = ((((pxyz)[i]))[1]);
            let edges = null;
            edges = [];
            for (let j = (((v.length) - (1))); Number((j) >= (0)); j += (-1)) {
                if (Number(!(((complete)[j])))) {
                    x1 = ((((pxyz)[((((v)[j]))[0])]))[0]);
                    y1 = ((((pxyz)[((((v)[j]))[0])]))[1]);
                    x2 = ((((pxyz)[((((v)[j]))[1])]))[0]);
                    y2 = ((((pxyz)[((((v)[j]))[1])]))[1]);
                    x3 = ((((pxyz)[((((v)[j]))[2])]))[0]);
                    y3 = ((((pxyz)[((((v)[j]))[2])]))[1]);
                    inside = circumcircle(xp, yp, x1, y1, x2, y2, x3, y3, xcycr);
                    let xc = 0.0;
                    xc = ((xcycr)[0]);
                    let r = 0.0;
                    r = ((xcycr)[2]);
                    if (((Number((xc) < (xp))) && (Number((((((xp) - (xc))) * (((xp) - (xc))))) > (r))))) {
                        ((complete)[j] = 1);
                    }
                    ;
                    if (inside) {
                        (edges).splice((edges.length), 0, ([(((((v)[j]))[0])), (((((v)[j]))[1]))]));
                        (edges).splice((edges.length), 0, ([(((((v)[j]))[1])), (((((v)[j]))[2]))]));
                        (edges).splice((edges.length), 0, ([(((((v)[j]))[2])), (((((v)[j]))[0]))]));
                        /*GC*/ ((v)[j]) = null;
                        (v).splice((j), (1));
                        (complete).splice((j), (1));
                    }
                    ;
                }
                ;
            }
            ;
            for (let j = (0); Number((j) < (((edges.length) - (1)))); j += (1)) {
                for (let k = (((j) + (1))); Number((k) < (edges.length)); k += (1)) {
                    if (((Number((((((edges)[j]))[0])) == (((((edges)[k]))[1])))) && (Number((((((edges)[j]))[1])) == (((((edges)[k]))[0])))))) {
                        ((((edges)[j]))[0] = -1);
                        ((((edges)[j]))[1] = -1);
                        ((((edges)[k]))[0] = -1);
                        ((((edges)[k]))[1] = -1);
                    }
                    ;
                    if (((Number((((((edges)[j]))[0])) == (((((edges)[k]))[0])))) && (Number((((((edges)[j]))[1])) == (((((edges)[k]))[1])))))) {
                        ((((edges)[j]))[0] = -1);
                        ((((edges)[j]))[1] = -1);
                        ((((edges)[k]))[0] = -1);
                        ((((edges)[k]))[1] = -1);
                    }
                    ;
                }
                ;
            }
            ;
            for (let j = (0); Number((j) < (edges.length)); j += (1)) {
                if (((Number((((((edges)[j]))[0])) < (0))) || (Number((((((edges)[j]))[1])) < (0))))) {
                }
                else {
                    (v).splice((v.length), 0, ([(((((edges)[j]))[0])), (((((edges)[j]))[1])), (i)]));
                    (complete).splice((complete.length), 0, (0));
                }
                ;
                /*GC*/ ((edges)[j]) = null;
            }
            ;
            /*GC*/ edges = null;
        }
        ;
        for (let i = (((v.length) - (1))); Number((i) >= (0)); i += (-1)) {
            if (((((Number((((((v)[i]))[0])) >= (nv))) || (Number((((((v)[i]))[1])) >= (nv))))) || (Number((((((v)[i]))[0])) >= (nv))))) {
                /*GC*/ ((v)[i]) = null;
                (v).splice((i), (1));
            }
            ;
        }
        ;
        /*GC*/ ((pxyz)[((pxyz.length) - (1))]) = null;
        /*GC*/ ((pxyz)[((pxyz.length) - (2))]) = null;
        /*GC*/ ((pxyz)[((pxyz.length) - (3))]) = null;
        (pxyz).splice((((pxyz.length) - (3))), (3));
        /*GC*/ complete = null;
        /*GC*/ xcycr = null;
        return v;
    }
    vororelax.delaunaytriangulate = delaunaytriangulate;
    ;
    function comparex(v1, v2) {
        if (Number((((v1)[0])) < (((v2)[0])))) {
            return -1;
        }
        else {
            if (Number((((v1)[0])) > (((v2)[0])))) {
                return 1;
            }
            ;
        }
        ;
        return 0;
    }
    vororelax.comparex = comparex;
    ;
    class site {
        constructor() {
            this.x = 0.0;
            this.y = 0.0;
            this.angles = null;
            this.cell = null;
        }
    }
    vororelax.site = site;
    ;
    function sortbyxf(A, inds, lo, hi) {
        if (Number((lo) >= (hi))) {
            return;
        }
        ;
        let pivot = null;
        pivot = ((A)[lo]);
        let left = 0;
        left = lo;
        let right = 0;
        right = hi;
        while (Number((left) <= (right))) {
            while (Number((comparex(((A)[left]), pivot)) < (0))) {
                left = ((left) + (1));
            }
            ;
            while (Number((comparex(((A)[right]), pivot)) > (0))) {
                right = ((right) - (1));
            }
            ;
            if (Number((left) <= (right))) {
                let tmp = null;
                tmp = ((A)[left]);
                ((A)[left] = ((A)[right]));
                ((A)[right] = tmp);
                let tmp2 = 0;
                tmp2 = ((inds)[left]);
                ((inds)[left] = ((inds)[right]));
                ((inds)[right] = tmp2);
                left = ((left) + (1));
                right = ((right) - (1));
            }
            ;
        }
        ;
        sortbyxf(A, inds, lo, right);
        sortbyxf(A, inds, left, hi);
    }
    vororelax.sortbyxf = sortbyxf;
    ;
    function siteaddvertex(st, x, y) {
        let ang = 0.0;
        ang = atan2(((y) - (((st).y))), ((x) - (((st).x))));
        let xy = null;
        xy = [(x), (y)];
        let n = 0;
        n = ((st).cell).length;
        for (let i = (0); Number((i) < (n)); i += (1)) {
            if (Number((ang) < (((((st).angles))[i])))) {
                (((st).cell)).splice((i), 0, (xy));
                (((st).angles)).splice((i), 0, (ang));
                return;
            }
            ;
        }
        ;
        (((st).cell)).splice((n), 0, (xy));
        (((st).angles)).splice((n), 0, (ang));
    }
    vororelax.siteaddvertex = siteaddvertex;
    ;
    function ptinconvex(x, y, poly) {
        for (let i = (0); Number((i) < (poly.length)); i += (1)) {
            let x0 = 0.0;
            x0 = ((((poly)[i]))[0]);
            let y0 = 0.0;
            y0 = ((((poly)[i]))[1]);
            let x1 = 0.0;
            x1 = ((((poly)[((((i) + (1))) % (poly.length))]))[0]);
            let y1 = 0.0;
            y1 = ((((poly)[((((i) + (1))) % (poly.length))]))[1]);
            let side = 0.0;
            side = ((((((x) - (x0))) * (((y1) - (y0))))) - (((((x1) - (x0))) * (((y) - (y0))))));
            if (Number((side) > (0))) {
                return 0;
            }
            ;
        }
        ;
        return 1;
    }
    vororelax.ptinconvex = ptinconvex;
    ;
    function prunecell(st) {
        let n = 0;
        n = ((st).cell).length;
        if (((Number((n) < (3))) || (Number(!(ptinconvex(((st).x), ((st).y), ((st).cell))))))) {
            for (let i = (0); Number((i) < (n)); i += (1)) {
                /*GC*/ ((((st).cell))[i]) = null;
            }
            ;
            (((st).cell)).splice((0), (n));
        }
        ;
    }
    vororelax.prunecell = prunecell;
    ;
    function makevoronoi(pxyz, triangles) {
        let sites = null;
        sites = [];
        let circ = null;
        circ = (new Array(3)['fill'](0.0));
        for (let i = (0); Number((i) < (pxyz.length)); i += (1)) {
            let st = null;
            st = (new site());
            ((st).x = ((((pxyz)[i]))[0]));
            ((st).y = ((((pxyz)[i]))[1]));
            ((st).angles = []);
            ((st).cell = []);
            (sites).splice((sites.length), 0, (st));
        }
        ;
        for (let i = (0); Number((i) < (triangles.length)); i += (1)) {
            let p0 = 0;
            p0 = ((((triangles)[i]))[0]);
            let p1 = 0;
            p1 = ((((triangles)[i]))[1]);
            let p2 = 0;
            p2 = ((((triangles)[i]))[2]);
            circumcircle(0, 0, ((((pxyz)[p0]))[0]), ((((pxyz)[p0]))[1]), ((((pxyz)[p1]))[0]), ((((pxyz)[p1]))[1]), ((((pxyz)[p2]))[0]), ((((pxyz)[p2]))[1]), circ);
            siteaddvertex(((sites)[p0]), ((circ)[0]), ((circ)[1]));
            siteaddvertex(((sites)[p1]), ((circ)[0]), ((circ)[1]));
            siteaddvertex(((sites)[p2]), ((circ)[0]), ((circ)[1]));
        }
        ;
        for (let i = (0); Number((i) < (sites.length)); i += (1)) {
            prunecell(((sites)[i]));
        }
        ;
        /*GC*/ circ = null;
        return sites;
    }
    vororelax.makevoronoi = makevoronoi;
    ;
    function freesites(sites) {
        for (let i = (0); Number((i) < (sites.length)); i += (1)) {
            /*GC*/ ((((sites)[i])).angles) = null;
            for (let j = (0); Number((j) < (((((sites)[i])).cell).length)); j += (1)) {
                /*GC*/ ((((((sites)[i])).cell))[j]) = null;
            }
            ;
            /*GC*/ ((((sites)[i])).cell) = null;
            /*GC*/ ((sites)[i]) = null;
        }
        ;
        /*GC*/ sites = null;
    }
    vororelax.freesites = freesites;
    ;
    function convexcentroid(poly, ctrd) {

        let n = 0;
        n = poly.length;
        let det = 0.0;
        det = 0;
        let j = 0;
        j = 0;
        let cx = 0.0;
        cx = 0;
        let cy = 0.0;
        cy = 0;
        for (let i = (0); Number((i) < (n)); i += (1)) {
            j = ((((i) + (1))) % (n));
            let x0 = 0.0;
            x0 = ((((poly)[i]))[0]);
            let y0 = 0.0;
            y0 = ((((poly)[i]))[1]);
            let x1 = 0.0;
            x1 = ((((poly)[j]))[0]);
            let y1 = 0.0;
            y1 = ((((poly)[j]))[1]);
            let d = 0.0;
            d = ((((x0) * (y1))) - (((x1) * (y0))));
            det = ((det) + (d));
            cx = ((cx) + (((d) * (((x0) + (x1))))));
            cy = ((cy) + (((d) * (((y0) + (y1))))));
        }
        ;
        cx = ((cx) / (((3) * (det))));
        cy = ((cy) / (((3) * (det))));
        ((ctrd)[0] = cx);
        ((ctrd)[1] = cy);
    }
    vororelax.convexcentroid = convexcentroid;
    ;
    function lloydrelax(pxyz, fixedf) {

        sortbyxf(pxyz, fixedf, 0, ((pxyz.length) - (1)));
        let triangles = null;
        triangles = delaunaytriangulate(pxyz);

        let sites = null;
        sites = makevoronoi(pxyz, triangles);
        // console.log(JSON.stringify(sites))
        for (let i = (0); Number((i) < (sites.length)); i += (1)) {
            if (!sites[i].cell.length){
                continue;
            }
            // if (((Number(!(((fixedf)[i])))) && (((((sites)[i])).cell).length))) {
                convexcentroid(((((sites)[i])).cell), ((pxyz)[i]));
            // }
            ;
        }
        ;
        for (let i = (0); Number((i) < (triangles.length)); i += (1)) {
            /*GC*/ ((triangles)[i]) = null;
        }
        ;
        /*GC*/ triangles = null;
        return sites;
    }
    vororelax.lloydrelax = lloydrelax;
    ;
    function renderframe(w, h, sites, idx, total) {
        let s = null;
        s = "<g opacity=\"0\"><animate attributeName=\"opacity\" dur=\"5\" repeatCount=\"indefinite\" calcMode=\"linear\" values=\"0;";
        for (let i = (0); Number((i) < (total)); i += (1)) {
            ((s) += (((Number((idx) == (i))) ? ("1;") : ("0;"))));
        }
        ;
        ((s) += ("0\"/>"));
        for (let i = (0); Number((i) < (sites.length)); i += (1)) {
            if (((((sites)[i])).cell).length) {
                ((s) += ("<path d=\""));
                for (let j = (0); Number((j) < (((((sites)[i])).cell).length)); j += (1)) {
                    ((s) += (((j) ? ("L") : ("M"))));
                    ((s) += ((((((((((sites)[i])).cell))[j]))[0])).toString()));
                    ((s) += (","));
                    ((s) += ((((((((((sites)[i])).cell))[j]))[1])).toString()));
                    ((s) += (" "));
                }
                ;
                ((s) += ("z\" fill=\"none\" stroke=\"black\"/>"));
            }
            ;
            ((s) += ("<circle cx=\""));
            ((s) += ((((((sites)[i])).x)).toString()));
            ((s) += ("\" cy=\""));
            ((s) += ((((((sites)[i])).y)).toString()));
            ((s) += ("\" r=\"2\" fill=\"black\" />"));
        }
        ;
        ((s) += ("</g>"));
        return s;
    }
    vororelax.renderframe = renderframe;
    ;
    function main(pxyz,bounds,maxiter=10) {
        var [xmin,ymin,xmax,ymax]=bounds;
        let fixedfilter = null;
        fixedfilter = [];
        for (let i = (0); Number((i) < (pxyz.length)); i += (1)) {
            (fixedfilter).push(i);
        }
        ;
        // let maxiter = 0;
        // maxiter = 10;
        let sites = null;

        for (let iter = (0); Number((iter) < (maxiter)); iter += (1)) {
            if (iter % 10 == 0 || iter==maxiter-1){
                console.log(`voronoi relax iter ${iter}/${maxiter}`)
            }
            sites = lloydrelax(pxyz, fixedfilter);
            for (var i = 0; i < pxyz.length; i++){
                pxyz[i][0] = Math.min(Math.max(pxyz[i][0],xmin),xmax)
                pxyz[i][1] = Math.min(Math.max(pxyz[i][1],ymin),ymax)
                sites[i].x = Math.min(Math.max(sites[i].x,xmin),xmax)
                sites[i].y = Math.min(Math.max(sites[i].y,ymin),ymax)
            }
        }
        let ret = []
        for (var i = 0; i < fixedfilter.length;i++){
            ret[fixedfilter[i]]=sites[i]
        }
        return ret
    }
    vororelax.main = main;
    ;
    /*=== User Code            END   ===*/
    // @ts-ignore
})(vororelax || (vororelax = {}));
module.exports = vororelax;
